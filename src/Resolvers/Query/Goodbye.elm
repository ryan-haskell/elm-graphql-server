module Resolvers.Query.Goodbye exposing (resolver)

import GraphQL


resolver : () -> () -> GraphQL.Response String
resolver parent args =
    Ok "Goodbye!"
