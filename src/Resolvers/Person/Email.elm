module Resolvers.Person.Email exposing (resolver)

import GraphQL.Response exposing (Response)
import Resolvers.Query.Person exposing (Person)


resolver : Person -> () -> Response (Maybe String)
resolver person args =
    GraphQL.Response.ok person.email
