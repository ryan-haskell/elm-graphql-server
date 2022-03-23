module Resolvers.Post.ImageUrls exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)


resolver : Post -> () -> Response (List String)
resolver post args =
    GraphQL.Response.ok post.imageUrls
