module Resolvers.User.Id exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema


resolver : Schema.User -> () -> Response Int
resolver (Schema.User user) _ =
    GraphQL.Response.ok user.id
