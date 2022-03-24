module Resolvers.Query.Posts exposing (resolver)

import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Resolvers.Post.Author
import Schema.Post exposing (Post)
import Schema.User exposing (User)
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.Posts
import Table.Posts.Select
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.Id
import Table.Users
import Table.Users.Where.Id


resolver : Info -> () -> () -> Response (List Post)
resolver info _ args =
    let
        isSelectingAuthor : Bool
        isSelectingAuthor =
            GraphQL.Info.hasSelection "author" info

        postsQuery : Response (List Post)
        postsQuery =
            Table.Posts.findAll
                { where_ = Nothing
                , limit = Just 25
                , select = Schema.Post.selectAll
                }
                |> GraphQL.Response.fromDatabaseQuery
    in
    if isSelectingAuthor then
        postsQuery
            |> GraphQL.Response.andThen Resolvers.Post.Author.includeForList

    else
        postsQuery
