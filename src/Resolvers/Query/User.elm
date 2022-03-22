module Resolvers.Query.User exposing (argumentsDecoder, resolver)

import Database.Where
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select
import Table.Users.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : () -> Arguments -> Response (Maybe User)
resolver parent args =
    Table.Users.findOne
        { where_ = Just (Table.Users.Where.Id.equals args.id)
        , select =
            Table.Users.Select.new User
                |> Table.Users.Select.id
                |> Table.Users.Select.username
                |> Table.Users.Select.avatarUrl
        }
        |> GraphQL.Response.fromDatabaseQuery
