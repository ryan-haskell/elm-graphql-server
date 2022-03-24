module Resolvers.Post.Caption exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema
import Schema.Post exposing (Post)


resolver : Schema.Post -> () -> Response String
resolver (Schema.Post post) args =
    GraphQL.Response.ok post.caption
