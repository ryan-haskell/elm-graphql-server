module Resolvers.Post.Id exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema


resolver : Schema.Post -> () -> Response Int
resolver (Schema.Post post) _ =
    GraphQL.Response.ok post.id
