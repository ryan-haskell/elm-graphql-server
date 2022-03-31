module Resolvers.Post.CreatedAt exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema
import Time


resolver : Schema.Post -> () -> Response Time.Posix
resolver (Schema.Post post) _ =
    GraphQL.Response.ok post.createdAt
