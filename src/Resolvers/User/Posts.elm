module Resolvers.User.Posts exposing (resolver)

import Database.Include
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import List.Extra
import Schema exposing (Post, User)
import Schema.Post
import Schema.User
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.Posts
import Table.Posts.Where.Id
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.UserId
import Table.Users.Where.Id


resolver : Info -> Schema.User -> () -> Response (List Post)
resolver info (Schema.User user) args =
    GraphQL.Response.batchList
        { id = user.id
        , info = info
        , toBatchResponse = toBatchResponse
        }



-- INTERNALS


toBatchResponse : List Int -> Response (List (List Post))
toBatchResponse userIds =
    fetchUserAuthoredPostEdges userIds
        |> GraphQL.Response.andThen (fetchPostsAndGroupByUserId userIds)


fetchUserAuthoredPostEdges : List Int -> Response (List UserAuthoredPost)
fetchUserAuthoredPostEdges userIds =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        , where_ = Just (Table.UserAuthoredPost.Where.UserId.in_ userIds)
        }
        |> GraphQL.Response.fromDatabaseQuery


fetchPosts : List UserAuthoredPost -> Response (List Post)
fetchPosts edges =
    Table.Posts.findAll
        { select = Schema.Post.selectAll
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        , where_ = Just (Table.Posts.Where.Id.in_ (List.map .postId edges))
        }
        |> GraphQL.Response.fromDatabaseQuery


fetchPostsAndGroupByUserId : List Int -> List UserAuthoredPost -> Response (List (List Post))
fetchPostsAndGroupByUserId userIds edges =
    let
        groupByUserId : List Post -> List (List Post)
        groupByUserId posts =
            List.map (postsByUserId posts) userIds

        postsByUserId : List Post -> Int -> List Post
        postsByUserId posts userId =
            let
                edgesMatchingThisUser : List UserAuthoredPost
                edgesMatchingThisUser =
                    List.filter (\edge -> edge.userId == userId) edges

                postsMatchingThisUser : List Post
                postsMatchingThisUser =
                    List.concatMap findPostsForEdge edgesMatchingThisUser

                findPostsForEdge : UserAuthoredPost -> List Post
                findPostsForEdge edge =
                    List.filter (\(Schema.Post post) -> post.id == edge.postId) posts
            in
            postsMatchingThisUser
    in
    fetchPosts edges
        |> GraphQL.Response.map groupByUserId
