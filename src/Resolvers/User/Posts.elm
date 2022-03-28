module Resolvers.User.Posts exposing (resolver)

import Database.Query
import GraphQL.Batch
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Schema exposing (Post, User)
import Schema.Post
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.Posts
import Table.Posts.Where.Id
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.UserId


resolver : Info -> Schema.User -> () -> Response (List Post)
resolver info (Schema.User user) args =
    GraphQL.Batch.oneToMany
        { id = user.id
        , info = info
        , fetchEdges = fetchEdges
        , fetchValues = fetchPosts
        , fromEdgeToKeyId = .userId
        , fromEdgeToValueId = .postId
        , fromValueToValueId = \(Schema.Post post) -> post.id
        }


fetchEdges : List Int -> Table.UserAuthoredPost.Query (List UserAuthoredPost)
fetchEdges userIds =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        , where_ = Just (Table.UserAuthoredPost.Where.UserId.in_ userIds)
        }


fetchPosts : List UserAuthoredPost -> Table.Posts.Query (List Post)
fetchPosts edges =
    Table.Posts.findAll
        { select = Schema.Post.selectAll
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        , where_ = Just (Table.Posts.Where.Id.in_ (List.map .postId edges))
        }
