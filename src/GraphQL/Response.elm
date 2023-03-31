module GraphQL.Response exposing
    ( Response
    , ok, err
    , fromDatabaseQuery
    , fromOneToOneQuery
    , fromOneToManyQuery
    , map, andThen
    , toCmd
    )

{-|

@docs Response
@docs ok, err
@docs fromDatabaseQuery
@docs fromOneToOneQuery
@docs fromOneToManyQuery

@docs map, andThen
@docs toCmd

-}

import Database.Query
import Dict exposing (Dict)
import GraphQL.Info exposing (Info)
import Json.Decode
import Json.Encode
import List.Extra
import Task exposing (Task)


type Response value
    = Success value
    | Failure String
    | Batch
        { id : Int
        , toBatchResponse : List Int -> Response (Dict Int value)
        , fromDictToItem : Dict Int value -> value
        }
    | Query
        { sql : String
        , onResponse : Json.Decode.Value -> Response value
        }



-- CREATING A RESPONSE


ok : value -> Response value
ok value =
    Success value


err : String -> Response value
err reason =
    Failure reason


fromDatabaseQuery : Database.Query.Query column value -> Response value
fromDatabaseQuery query =
    Query
        { sql = Database.Query.toSql query
        , onResponse =
            \json ->
                case Json.Decode.decodeValue (Database.Query.toDecoder query) json of
                    Ok value ->
                        ok value

                    Err problem ->
                        err (Json.Decode.errorToString problem)
        }


type alias Id =
    Int



-- ONE TO MANY RELATIONSHIPS


{-| Useful when defining a field resolver for one-to-many relationships,
like fetching all posts for a given user:

    type User {
        posts: [Post!]!
    }

This helper function assumes all relationships are modeled consistently, where there are two
SQL queries needed to fetch the one-to-many relationship:

  - One to query the "join table" for all edges, given a list of "key ids"
  - One to query the "values table" for value data, based on the edges that came back from the previous query.

To be concrete, if we were getting all posts for a user, here's what each of these abstract variables
would correspond to:

  - Key ID = User ID (an int)
  - Value ID = Post ID (an int)
  - Edge = `UserAuthoredPost`

Because the `edge` is generic, this function also needs to know how to get data from the edge. For this example,
that would mean:

    type alias UserAuthoredEdge =
        { id : Int
        , userId : Int
        , postId : Int
        }

  - from = `.userId`
  - to = `.postId`

Finally, we need the `toId` function to know how to get the `id` for a "value". Because our example
is returning `Schema.Post` items, we would need something like this:

  - toId = `\(Schema.Post post) -> post.id`

-}
fromOneToManyQuery :
    { id : Id
    , fetchEdges : List Id -> Database.Query.Query a (List edge)
    , fetchNodes : List edge -> Database.Query.Query b (List value)
    , from : edge -> Id
    , to : edge -> Id
    , toId : value -> Id
    }
    -> Response (List value)
fromOneToManyQuery options =
    let
        toBatchResponse : List Id -> Response (Dict Id (List value))
        toBatchResponse userIds =
            options.fetchEdges userIds
                |> fromDatabaseQuery
                |> andThen toDict

        toDict : List edge -> Response (Dict Id (List value))
        toDict edges =
            let
                valueIdDict : Dict Id (List Id)
                valueIdDict =
                    edges
                        |> List.Extra.gatherEqualsBy options.from
                        |> List.map
                            (\( first, rest ) ->
                                ( options.from first
                                , List.map options.to (first :: rest)
                                )
                            )
                        |> Dict.fromList

                groupByKeyId : List value -> Dict Id (List value)
                groupByKeyId values =
                    let
                        updateDict : Id -> Dict Id (List value) -> Dict Id (List value)
                        updateDict keyId dict =
                            let
                                valueIds : List Id
                                valueIds =
                                    Dict.get keyId valueIdDict
                                        |> Maybe.withDefault []

                                valuesMatchingThisKey : List value
                                valuesMatchingThisKey =
                                    List.filter
                                        (\item ->
                                            List.member (options.toId item) valueIds
                                        )
                                        values
                            in
                            Dict.insert keyId valuesMatchingThisKey dict
                    in
                    List.foldl updateDict Dict.empty (Dict.keys valueIdDict)
            in
            options.fetchNodes edges
                |> fromDatabaseQuery
                |> map groupByKeyId
    in
    fromBatchQueryForList
        { id = options.id
        , toBatchResponse = toBatchResponse
        }


fromOneToOneQuery :
    { id : Id
    , fetchEdges : List Id -> Database.Query.Query a (List edge)
    , fetchNodes : List edge -> Database.Query.Query b (List value)
    , from : edge -> Id
    , to : edge -> Id
    , toId : value -> Id
    }
    -> Response (Maybe value)
fromOneToOneQuery options =
    let
        toBatchResponse : List Id -> Response (Dict Id value)
        toBatchResponse userIds =
            options.fetchEdges userIds
                |> fromDatabaseQuery
                |> andThen toDict

        toDict : List edge -> Response (Dict Id value)
        toDict edges =
            let
                valueIdDict : Dict Id (List Id)
                valueIdDict =
                    edges
                        |> List.Extra.gatherEqualsBy options.from
                        |> List.map
                            (\( first, rest ) ->
                                ( options.from first
                                , List.map options.to (first :: rest)
                                )
                            )
                        |> Dict.fromList

                groupByKeyId : List value -> Dict Id value
                groupByKeyId values =
                    let
                        updateDict : Id -> Dict Id value -> Dict Id value
                        updateDict keyId dict =
                            let
                                valueIds : List Id
                                valueIds =
                                    Dict.get keyId valueIdDict
                                        |> Maybe.withDefault []

                                valuesMatchingThisKey : List value
                                valuesMatchingThisKey =
                                    List.filter
                                        (\item ->
                                            List.member (options.toId item) valueIds
                                        )
                                        values
                            in
                            case valuesMatchingThisKey of
                                [] ->
                                    dict

                                value :: _ ->
                                    Dict.insert keyId value dict
                    in
                    List.foldl updateDict Dict.empty (Dict.keys valueIdDict)
            in
            options.fetchNodes edges
                |> fromDatabaseQuery
                |> map groupByKeyId
    in
    fromBatchQueryForMaybe
        { id = options.id
        , toBatchResponse = toBatchResponse
        }



-- INTERNALS


fromBatchQueryForMaybe :
    { id : Int
    , toBatchResponse : List Int -> Response (Dict Int value)
    }
    -> Response (Maybe value)
fromBatchQueryForMaybe options =
    let
        fromDictToItem : Dict Int (Maybe value) -> Maybe value
        fromDictToItem =
            Dict.get options.id >> Maybe.andThen identity

        toMaybeDict : Response (Dict Int value) -> Response (Dict Int (Maybe value))
        toMaybeDict =
            map (Dict.map (always Just))
    in
    Batch
        { id = options.id
        , toBatchResponse = options.toBatchResponse >> toMaybeDict
        , fromDictToItem = fromDictToItem
        }


fromBatchQueryForList :
    { id : Int
    , toBatchResponse : List Int -> Response (Dict Int (List value))
    }
    -> Response (List value)
fromBatchQueryForList options =
    let
        fromDictToItem : Dict Int (List value) -> List value
        fromDictToItem =
            Dict.get options.id >> Maybe.withDefault []

        toMaybeDict : Response (Dict Int (List value)) -> Response (Dict Int (Maybe (List value)))
        toMaybeDict =
            map (Dict.map (always Just))
    in
    Batch
        { id = options.id
        , toBatchResponse = options.toBatchResponse
        , fromDictToItem = fromDictToItem
        }



-- FUNCTIONS


map : (a -> b) -> Response a -> Response b
map fn response =
    case response of
        Success value ->
            Success (fn value)

        Failure reason ->
            Failure reason

        Query data ->
            Query
                { sql = data.sql
                , onResponse = \json -> map fn (data.onResponse json)
                }

        Batch data ->
            Failure "Batched queries do not support Response.map"


andThen : (a -> Response b) -> Response a -> Response b
andThen toResponse response =
    case response of
        Success value ->
            toResponse value

        Failure reason ->
            Failure reason

        Query data ->
            Query
                { sql = data.sql
                , onResponse = \json -> andThen toResponse (data.onResponse json)
                }

        Batch data ->
            Failure "Batched queries do not support Response.andThen"


toCmd :
    { info : Info
    , onSuccess : value -> Cmd msg
    , onFailure : String -> Cmd msg
    , onDatabaseQuery :
        { sql : String
        , onResponse : Json.Decode.Value -> Cmd msg
        }
        -> msg
    , onBatchQuery :
        { id : Int
        , info : Info
        , onResponse : List Int -> Cmd msg
        }
        -> msg
    }
    -> Response value
    -> Cmd msg
toCmd options response =
    case response of
        Success value ->
            options.onSuccess value

        Failure reason ->
            options.onFailure reason

        Query query ->
            sendMessage
                (options.onDatabaseQuery
                    { sql = query.sql
                    , onResponse = \json -> toCmd options (query.onResponse json)
                    }
                )

        Batch query ->
            let
                onResponse : List Int -> Cmd msg
                onResponse ints =
                    query.toBatchResponse ints
                        |> map query.fromDictToItem
                        |> toCmd options
            in
            sendMessage
                (options.onBatchQuery
                    { id = query.id
                    , info = options.info
                    , onResponse = onResponse
                    }
                )


sendMessage : msg -> Cmd msg
sendMessage msg =
    Task.succeed msg |> Task.perform identity
