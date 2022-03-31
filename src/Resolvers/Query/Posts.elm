module Resolvers.Query.Posts exposing (resolver)

import Database.Order
import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)
import Table.Posts
import Table.Posts.Column


resolver : () -> () -> Response (List Post)
resolver _ _ =
    Table.Posts.findAll
        { select = Schema.Post.selectAll
        , where_ = Nothing
        , orderBy = Just (Database.Order.descending Table.Posts.Column.createdAt)
        , limit = Just 25
        , offset = Nothing
        }
        |> GraphQL.Response.fromDatabaseQuery
