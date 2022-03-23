module Resolvers.Query.Post exposing (argumentsDecoder, resolver)

import Database.Where
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
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


resolver : () -> Arguments -> Response (Maybe Post)
resolver parent args =
    Table.Posts.findOne
        { where_ = Just (Table.Posts.Where.Id.equals args.id)
        , select =
            Table.Posts.Select.new Post
                |> Table.Posts.Select.id
                |> Table.Posts.Select.imageUrls
                |> Table.Posts.Select.caption
                |> Table.Posts.Select.createdAt
        }
        |> GraphQL.Response.fromDatabaseQuery
