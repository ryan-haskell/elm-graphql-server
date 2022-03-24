module Resolvers.Query.Post exposing (argumentsDecoder, resolver)

import Database.Where
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Resolvers.Post.Author
import Schema.Post exposing (Post)
import Table.Posts
import Table.Posts.Select
import Table.Posts.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : Info -> () -> Arguments -> Response (Maybe Post)
resolver info parent args =
    let
        findPost : Response (Maybe Post)
        findPost =
            Table.Posts.findOne
                { where_ = Just (Table.Posts.Where.Id.equals args.id)
                , select = Schema.Post.selectAll
                }
                |> GraphQL.Response.fromDatabaseQuery
    in
    if GraphQL.Info.hasSelection "author" info then
        findPost
            |> GraphQL.Response.andThen Resolvers.Post.Author.includeForMaybe

    else
        findPost
