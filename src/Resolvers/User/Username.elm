module Resolvers.User.Username exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema


resolver : Schema.User -> () -> Response String
resolver (Schema.User user) args =
    GraphQL.Response.ok user.username
