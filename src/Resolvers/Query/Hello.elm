module Resolvers.Query.Hello exposing (resolver)

import GraphQL


resolver : () -> { name : String } -> GraphQL.Response String
resolver parent args =
    Ok ("Hey, " ++ args.name ++ "!")
