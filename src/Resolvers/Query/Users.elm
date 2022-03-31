module Resolvers.Query.Users exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.User exposing (User)
import Table.Users


resolver : () -> () -> Response (List User)
resolver _ _ =
    Table.Users.findAll
        { where_ = Nothing
        , limit = Just 25
        , offset = Nothing
        , orderBy = Nothing
        , select = Schema.User.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
