module Resolvers.Post.Author exposing (resolver)

import GraphQL.Response exposing (Response)
import Schema exposing (Post, User)
import Schema.User
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.PostId
import Table.Users
import Table.Users.Where.Id


resolver : Post -> () -> Response (Maybe User)
resolver (Schema.Post post) _ =
    GraphQL.Response.fromOneToOneQuery
        { id = post.id
        , fetchEdges = fetchEdges
        , fetchNodes = fetchUsers
        , from = .postId
        , to = .userId
        , toId = Schema.User.id
        }


fetchEdges : List Int -> Table.UserAuthoredPost.Query (List UserAuthoredPost)
fetchEdges postIds =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , where_ = Just (Table.UserAuthoredPost.Where.PostId.in_ postIds)
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        }


fetchUsers : List UserAuthoredPost -> Table.Users.Query (List User)
fetchUsers edges =
    Table.Users.findAll
        { select = Schema.User.selectAll
        , where_ = Just (Table.Users.Where.Id.in_ (List.map .userId edges))
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        }
