module Resolvers.Post.Author exposing
    ( resolver
    , include, includeForList, includeForMaybe
    )

{-|

@docs resolver

@docs include, includeForList, includeForMaybe

-}

import Database.Include
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


resolver : Post -> () -> Response (Maybe User)
resolver (Schema.Post post) args =
    GraphQL.Response.ok post.author


include : Post -> Response Post
include post =
    Database.Include.fromListToItem
        includeForList
        post


includeForMaybe : Maybe Post -> Response (Maybe Post)
includeForMaybe maybePost =
    Database.Include.fromListToMaybe
        includeForList
        maybePost


includeForList : List Post -> Response (List Post)
includeForList posts =
    fetchUserAuthoredPostEdges posts
        |> GraphQL.Response.andThen (fetchAuthorsFor posts)



-- INTERNALS


fetchUserAuthoredPostEdges : List Post -> Response (List UserAuthoredPost)
fetchUserAuthoredPostEdges posts =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , limit = Nothing
        , where_ = Just (Table.UserAuthoredPost.Where.PostId.in_ (List.map Schema.Post.id posts))
        }
        |> GraphQL.Response.fromDatabaseQuery


fetchAuthorsFor : List Post -> List UserAuthoredPost -> Response (List Post)
fetchAuthorsFor posts edges =
    Table.Users.findAll
        { select = Schema.User.selectAll
        , limit = Nothing
        , where_ = Just (Table.Users.Where.Id.in_ (List.map .userId edges))
        }
        |> GraphQL.Response.fromDatabaseQuery
        |> GraphQL.Response.map (fillInPostsWithAuthors posts edges)


fillInPostsWithAuthors : List Post -> List UserAuthoredPost -> List User -> List Post
fillInPostsWithAuthors posts edges users =
    List.map (updatePostWithMatchingUser edges users) posts


updatePostWithMatchingUser : List UserAuthoredPost -> List User -> Post -> Post
updatePostWithMatchingUser edges users (Schema.Post post) =
    let
        edgesMatchingThisPost : List UserAuthoredPost
        edgesMatchingThisPost =
            List.filter (\edge -> edge.postId == post.id) edges

        usersMatchingThisPost : List User
        usersMatchingThisPost =
            List.filterMap findUserForEdge edgesMatchingThisPost

        findUserForEdge : UserAuthoredPost -> Maybe User
        findUserForEdge edge =
            List.Extra.find (\(Schema.User user) -> user.id == edge.userId) users
    in
    Schema.Post { post | author = List.head usersMatchingThisPost }
