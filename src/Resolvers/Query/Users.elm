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
        , select =
            Table.Users.Select.new User
                |> Table.Users.Select.id
                |> Table.Users.Select.username
                |> Table.Users.Select.avatarUrl
        }
        |> GraphQL.Response.fromDatabaseQuery
