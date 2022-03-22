module Resolvers.Mutation.CreateUser exposing (argumentsDecoder, resolver)

import GraphQL.Response
import Json.Decode
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select
import Table.Users.Value


type alias Arguments =
    { username : String
    , avatarUrl : Maybe String
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map2 Arguments
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "avatarUrl" Json.Decode.string))


resolver : () -> Arguments -> GraphQL.Response.Response User
resolver _ args =
    Table.Users.insertOne
        { values =
            [ Table.Users.Value.username args.username
            , Table.Users.Value.avatarUrl args.avatarUrl
            ]
        , returning =
            Table.Users.Select.new User
                |> Table.Users.Select.id
                |> Table.Users.Select.username
                |> Table.Users.Select.avatarUrl
        }
        |> GraphQL.Response.fromDatabaseQuery
