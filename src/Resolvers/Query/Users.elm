module Resolvers.Query.Users exposing (resolver)

import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Resolvers.User.Posts
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select


resolver : () -> () -> Response (List User)
resolver _ args =
    Table.Users.findAll
        { where_ = Nothing
        , limit = Just 25
        , offset = Nothing
        , orderBy = Nothing
        , select = Schema.User.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
