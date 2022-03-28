module GraphQL.Response exposing
    ( Response
    , ok, err
    , fromDatabaseQuery
    , fromBatchQueryForMaybe
    , fromBatchQueryForList
    , map, andThen
    , toCmd
    )

{-|

@docs Response
@docs ok, err
@docs fromDatabaseQuery
@docs fromBatchQueryForMaybe
@docs fromBatchQueryForList

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
        , info : Info
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


fromBatchQueryForMaybe :
    { id : Int
    , info : Info
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
        , info = options.info
        , toBatchResponse = options.toBatchResponse >> toMaybeDict
        , fromDictToItem = fromDictToItem
        }


fromBatchQueryForList :
    { id : Int
    , info : Info
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
        , info = options.info
        , toBatchResponse = options.toBatchResponse
        , fromDictToItem = fromDictToItem
        }


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
    { onSuccess : value -> Cmd msg
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
                    , info = query.info
                    , onResponse = onResponse
                    }
                )


sendMessage : msg -> Cmd msg
sendMessage msg =
    Task.succeed msg |> Task.perform identity
