module Resolvers.Query.User exposing (argumentsDecoder, resolver)

import Database.Where
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Resolvers.User.Posts
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


resolver : Info -> () -> Arguments -> Response (Maybe User)
resolver info _ args =
    let
        fetchUser =
            Table.Users.findOne
                { where_ = Just (Table.Users.Where.Id.equals args.id)
                , select = Schema.User.selectAll
                }
                |> GraphQL.Response.fromDatabaseQuery
    in
    if GraphQL.Info.hasSelection "posts" info then
        fetchUser
            |> GraphQL.Response.andThen Resolvers.User.Posts.includeForMaybe

    else
        fetchUser
