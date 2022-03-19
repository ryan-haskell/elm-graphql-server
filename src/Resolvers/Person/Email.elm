module Resolvers.Person.Email exposing (resolver)

import GraphQL
import Resolvers.Query.Person exposing (Person)


resolver : Person -> () -> GraphQL.Response (Maybe String)
resolver person args =
    Ok person.email
