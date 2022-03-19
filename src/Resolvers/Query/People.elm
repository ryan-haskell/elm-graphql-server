module Resolvers.Query.People exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.Person exposing (Person)
import Table.People
import Table.People.Select


resolver : () -> () -> Response (List Person)
resolver _ args =
    Table.People.findAll
        { where_ = Nothing
        , limit = Just 25
        , select =
            Table.People.Select.new Person
                |> Table.People.Select.id
                |> Table.People.Select.name
                |> Table.People.Select.email
        }
        |> GraphQL.Response.fromDatabaseQuery
