module Resolvers.User.Username exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.User exposing (User)


resolver : User -> () -> Response String
resolver user args =
    GraphQL.Response.ok user.username
