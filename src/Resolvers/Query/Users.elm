module Resolvers.Query.Users exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select


resolver : () -> () -> Response (List User)
resolver _ args =
    Table.Users.findAll
        { where_ = Nothing
        , limit = Just 25
        , select = Schema.User.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
