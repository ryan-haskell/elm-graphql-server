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
        , select = Schema.Post.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
