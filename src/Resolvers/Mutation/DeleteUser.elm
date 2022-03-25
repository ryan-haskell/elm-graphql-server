module Resolvers.Mutation.DeleteUser exposing (argumentsDecoder, resolver)

import GraphQL.Info exposing (Info)
import GraphQL.Response
import Json.Decode
import Resolvers.User.Posts
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select
import Table.Users.Value
import Table.Users.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : Info -> () -> Arguments -> GraphQL.Response.Response (Maybe User)
resolver info _ args =
    let
        deleteUser =
            Table.Users.deleteOne
                { where_ = Just (Table.Users.Where.Id.equals args.id)
                , returning = Schema.User.selectAll
                }
                |> GraphQL.Response.fromDatabaseQuery
    in
    if GraphQL.Info.hasSelection "posts" info then
        deleteUser
            |> GraphQL.Response.andThen Resolvers.User.Posts.includeForMaybe

    else
        deleteUser
