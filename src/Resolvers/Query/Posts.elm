module Resolvers.Query.Posts exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)
import Table.Posts
import Table.Posts.Select


resolver : () -> () -> Response (List Post)
resolver _ args =
    Table.Posts.findAll
        { where_ = Nothing
        , limit = Just 25
        , select =
            Table.Posts.Select.new Post
                |> Table.Posts.Select.id
                |> Table.Posts.Select.imageUrls
                |> Table.Posts.Select.caption
                |> Table.Posts.Select.createdAt
        }
        |> GraphQL.Response.fromDatabaseQuery
