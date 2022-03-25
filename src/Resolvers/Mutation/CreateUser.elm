module Resolvers.Mutation.CreateUser exposing (argumentsDecoder, resolver)

import GraphQL.Info exposing (Info)
import GraphQL.Response
import Json.Decode
import Resolvers.User.Posts
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


resolver : Info -> () -> Arguments -> GraphQL.Response.Response User
resolver info _ args =
    let
        insertUser =
            Table.Users.insertOne
                { values =
                    [ Table.Users.Value.username args.username
                    , Table.Users.Value.avatarUrl args.avatarUrl
                    ]
                , returning = Schema.User.selectAll
                }
                |> GraphQL.Response.fromDatabaseQuery
    in
    if GraphQL.Info.hasSelection "posts" info then
        insertUser
            |> GraphQL.Response.andThen Resolvers.User.Posts.include

    else
        insertUser
