module Resolvers.User.Posts exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema


resolver : Schema.User -> () -> Response (List Schema.Post)
resolver (Schema.User user) args =
    GraphQL.Response.ok user.posts
