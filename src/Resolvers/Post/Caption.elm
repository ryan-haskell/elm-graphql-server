module Resolvers.Post.Caption exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema


resolver : Schema.Post -> () -> Response String
resolver (Schema.Post post) _ =
    GraphQL.Response.ok post.caption
