module Resolvers.Person.Name exposing (resolver)

import GraphQL
import Resolvers.Query.Person exposing (Person)


resolver : Person -> () -> GraphQL.Response String
resolver person args =
    Ok person.name
