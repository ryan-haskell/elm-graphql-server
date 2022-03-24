module Resolvers.Post.Location exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)


resolver : Post -> () -> Response (Maybe String)
resolver post args =
    GraphQL.Response.ok post.location
