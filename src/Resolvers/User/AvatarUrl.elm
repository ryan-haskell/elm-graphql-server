module Resolvers.User.AvatarUrl exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.User exposing (User)


resolver : User -> () -> Response (Maybe String)
resolver user args =
    GraphQL.Response.ok user.avatarUrl
