module Resolvers.Query.Posts exposing (resolver)

import Database.Order
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Resolvers.Post.Author
import Schema.Post exposing (Post)
import Schema.User exposing (User)
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.Posts
import Table.Posts.Column
import Table.Posts.Select
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.Id
import Table.Users
import Table.Users.Where.Id


resolver : () -> () -> Response (List Post)
resolver _ args =
    Table.Posts.findAll
        { select = Schema.Post.selectAll
        , where_ = Nothing
        , orderBy = Just (Database.Order.descending Table.Posts.Column.createdAt)
        , limit = Just 25
        , offset = Nothing
        }
        |> GraphQL.Response.fromDatabaseQuery
