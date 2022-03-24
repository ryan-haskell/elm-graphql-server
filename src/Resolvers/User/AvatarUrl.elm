module Resolvers.User.AvatarUrl exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema


resolver : Schema.User -> () -> Response (Maybe String)
resolver (Schema.User user) args =
    GraphQL.Response.ok user.avatarUrl
