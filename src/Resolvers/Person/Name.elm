module Resolvers.Person.Name exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.Person exposing (Person)


resolver : Person -> () -> Response String
resolver person args =
    GraphQL.Response.ok person.name
