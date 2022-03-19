module Resolvers.Query.Goodbye exposing (resolver)

import GraphQL.Response exposing (Response)


resolver : () -> () -> Response String
resolver parent args =
    GraphQL.Response.ok "Goodbye!"
