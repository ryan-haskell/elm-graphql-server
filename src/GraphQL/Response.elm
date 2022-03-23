module GraphQL.Response exposing
    ( Response
    , ok, err
    , fromDatabaseQuery
    , map, andThen
    , toCmd
    )

{-|

@docs Response
@docs ok, err
@docs fromDatabaseQuery

@docs map, andThen
@docs toCmd

-}

import Database.Query
import Json.Decode
import Json.Encode
import Task exposing (Task)


type Response value
    = Success value
    | Failure String
    | Query
        { sql : String
        , onResponse : Json.Decode.Value -> Response value
        }


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


toCmd :
    { onSuccess : value -> Cmd msg
    , onFailure : Json.Decode.Value -> Cmd msg
    , onDatabaseQuery :
        { sql : String
        , onResponse : Json.Decode.Value -> Cmd msg
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
            options.onFailure (Json.Encode.string reason)

        Query query ->
            sendMessage
                (options.onDatabaseQuery
                    { sql = query.sql
                    , onResponse = \json -> toCmd options (query.onResponse json)
                    }
                )


sendMessage : msg -> Cmd msg
sendMessage msg =
    Task.succeed msg |> Task.perform identity
