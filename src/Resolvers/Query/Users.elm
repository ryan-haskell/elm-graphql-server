module Resolvers.Query.Users exposing (resolver)

import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Resolvers.User.Posts
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select


resolver : Info -> () -> () -> Response (List User)
resolver info _ args =
    let
        fetchUsers =
            Table.Users.findAll
                { where_ = Nothing
                , limit = Just 25
                , select = Schema.User.selectAll
                }
                |> GraphQL.Response.fromDatabaseQuery
    in
    if GraphQL.Info.hasSelection "posts" info then
        fetchUsers
            |> GraphQL.Response.andThen Resolvers.User.Posts.includeForList

    else
        fetchUsers
