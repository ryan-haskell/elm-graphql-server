module Resolvers.Post.Author exposing (..)

import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)
import Schema.User exposing (User)


resolver : Post -> () -> Response (Maybe User)
resolver post args =
    GraphQL.Response.ok post.author
