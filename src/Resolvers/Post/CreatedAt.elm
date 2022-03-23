module Resolvers.Post.CreatedAt exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)
import Time


resolver : Post -> () -> Response Time.Posix
resolver post args =
    GraphQL.Response.ok post.createdAt
