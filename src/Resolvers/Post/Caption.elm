module Resolvers.Post.Caption exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)


resolver : Post -> () -> Response String
resolver post args =
    GraphQL.Response.ok post.caption
