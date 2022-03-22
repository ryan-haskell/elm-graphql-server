module Resolvers.User.Id exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.User exposing (User)


resolver : User -> () -> Response Int
resolver user args =
    GraphQL.Response.ok user.id
