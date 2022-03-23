module Resolvers.Post.Id exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)


resolver : Post -> () -> Response Int
resolver post args =
    GraphQL.Response.ok post.id
