module Resolvers.Post.Id exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema
import Schema.Post exposing (Post)


resolver : Schema.Post -> () -> Response Int
resolver (Schema.Post post) args =
    GraphQL.Response.ok post.id
