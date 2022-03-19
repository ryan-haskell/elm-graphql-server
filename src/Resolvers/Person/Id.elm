module Resolvers.Person.Id exposing (resolver)

import GraphQL
import Resolvers.Query.Person exposing (Person)
import Scalar.Id


resolver : Person -> () -> GraphQL.Response Scalar.Id.Id
resolver person args =
    Ok person.id
