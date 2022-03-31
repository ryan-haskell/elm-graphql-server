module Resolvers.User.Posts exposing (resolver)

import GraphQL.Batch
import GraphQL.Response exposing (Response)
import Schema exposing (Post)
import Schema.Post
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.Posts
import Table.Posts.Where.Id
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.UserId


resolver : Schema.User -> () -> Response (List Post)
resolver (Schema.User user) _ =
    GraphQL.Batch.forListOfValues
        { id = user.id
        , fetchEdges = fetchEdges
        , fetchValues = fetchPosts
        , fromEdgeToKeyId = .userId
        , fromEdgeToValueId = .postId
        , fromValueToValueId = Schema.Post.id
        }


fetchEdges : List Int -> Table.UserAuthoredPost.Query (List UserAuthoredPost)
fetchEdges userIds =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , where_ = Just (Table.UserAuthoredPost.Where.UserId.in_ userIds)
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        }


fetchPosts : List UserAuthoredPost -> Table.Posts.Query (List Post)
fetchPosts edges =
    Table.Posts.findAll
        { select = Schema.Post.selectAll
        , where_ = Just (Table.Posts.Where.Id.in_ (List.map .postId edges))
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        }
