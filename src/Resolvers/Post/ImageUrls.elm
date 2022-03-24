module Resolvers.Post.ImageUrls exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema


resolver : Schema.Post -> () -> Response (List String)
resolver (Schema.Post post) args =
    GraphQL.Response.ok post.imageUrls
