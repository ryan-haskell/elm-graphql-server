module Resolvers.Post.Author exposing (resolver)

import GraphQL.Batch
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Schema exposing (Post, User)
import Schema.User
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.PostId
import Table.Users
import Table.Users.Where.Id


resolver : Info -> Post -> () -> Response (Maybe User)
resolver info (Schema.Post post) args =
    GraphQL.Batch.forMaybeValue
        { id = post.id
        , info = info
        , fetchEdges = fetchEdges
        , fetchValues = fetchUsers
        , fromEdgeToKeyId = .postId
        , fromEdgeToValueId = .userId
        , fromValueToValueId = \(Schema.User user) -> user.id
        }


fetchEdges : List Int -> Table.UserAuthoredPost.Query (List UserAuthoredPost)
fetchEdges postIds =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        , where_ = Just (Table.UserAuthoredPost.Where.PostId.in_ postIds)
        }


fetchUsers : List UserAuthoredPost -> Table.Users.Query (List User)
fetchUsers edges =
    Table.Users.findAll
        { select = Schema.User.selectAll
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        , where_ = Just (Table.Users.Where.Id.in_ (List.map .userId edges))
        }
