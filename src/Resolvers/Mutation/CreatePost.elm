module Resolvers.Mutation.CreatePost exposing (argumentsDecoder, resolver)

import GraphQL.Response
import Json.Decode
import Schema.Post exposing (Post)
import Table.Posts
import Table.Posts.Select
import Table.Posts.Value
import Table.Users


type alias Arguments =
    { imageUrls : List String
    , caption : String
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map2 Arguments
        (Json.Decode.field "imageUrls" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "caption" Json.Decode.string)


resolver : () -> Arguments -> GraphQL.Response.Response Post
resolver _ args =
    Table.Posts.insertOne
        { values =
            [ Table.Posts.Value.imageUrls args.imageUrls
            , Table.Posts.Value.caption args.caption
            ]
        , returning =
            Table.Posts.Select.new Post
                |> Table.Posts.Select.id
                |> Table.Posts.Select.imageUrls
                |> Table.Posts.Select.caption
                |> Table.Posts.Select.createdAt
        }
        |> GraphQL.Response.fromDatabaseQuery
