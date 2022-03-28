module Resolvers.Post.Author exposing (resolver)

import Database.Include
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import List.Extra
import Schema
import Schema.Post exposing (Post)
import Schema.User exposing (User)
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.Id
import Table.UserAuthoredPost.Where.PostId
import Table.Users
import Table.Users.Where.Id


resolver : Info -> Post -> () -> Response (Maybe User)
resolver info (Schema.Post post) args =
    GraphQL.Response.batchMaybe
        { id = post.id
        , info = info
        , toBatchResponse = toBatchResponse
        }



-- INTERNALS


toBatchResponse : List Int -> Response (List (Maybe User))
toBatchResponse postIds =
    fetchUserAuthoredPostEdges postIds
        |> GraphQL.Response.andThen (fetchUsersAndGroupByPostId postIds)


fetchUserAuthoredPostEdges : List Int -> Response (List UserAuthoredPost)
fetchUserAuthoredPostEdges postIds =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        , where_ = Just (Table.UserAuthoredPost.Where.PostId.in_ postIds)
        }
        |> GraphQL.Response.fromDatabaseQuery


fetchUsers : List UserAuthoredPost -> Response (List User)
fetchUsers edges =
    Table.Users.findAll
        { select = Schema.User.selectAll
        , limit = Nothing
        , offset = Nothing
        , orderBy = Nothing
        , where_ = Just (Table.Users.Where.Id.in_ (List.map .userId edges))
        }
        |> GraphQL.Response.fromDatabaseQuery


fetchUsersAndGroupByPostId : List Int -> List UserAuthoredPost -> Response (List (Maybe User))
fetchUsersAndGroupByPostId postIds edges =
    let
        groupByPostId : List User -> List (Maybe User)
        groupByPostId users =
            List.map (usersForPostId users) postIds

        usersForPostId : List User -> Int -> Maybe User
        usersForPostId users postId =
            let
                edgesMatchingThisPost : List UserAuthoredPost
                edgesMatchingThisPost =
                    List.filter (\edge -> edge.postId == postId) edges

                usersMatchingThisPost : List User
                usersMatchingThisPost =
                    List.filterMap findUserForEdge edgesMatchingThisPost

                findUserForEdge : UserAuthoredPost -> Maybe User
                findUserForEdge edge =
                    List.Extra.find (\(Schema.User user) -> user.id == edge.userId) users
            in
            List.head usersMatchingThisPost
    in
    fetchUsers edges
        |> GraphQL.Response.map groupByPostId
