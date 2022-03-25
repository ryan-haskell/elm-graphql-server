module Resolvers.User.Posts exposing
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
import Schema.Post
import Schema.User
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.Posts
import Table.Posts.Where.Id
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.UserId
import Table.Users.Where.Id


resolver : Schema.User -> () -> Response (List Schema.Post)
resolver (Schema.User user) args =
    GraphQL.Response.ok user.posts


include : Schema.User -> Response Schema.User
include =
    Database.Include.fromListToItem includeForList


includeForMaybe : Maybe Schema.User -> Response (Maybe Schema.User)
includeForMaybe =
    Database.Include.fromListToMaybe includeForList


includeForList : List Schema.User -> Response (List Schema.User)
includeForList authors =
    fetchUserAuthoredPostEdgesFor authors
        |> GraphQL.Response.andThen (fetchPostsFor authors)


fetchUserAuthoredPostEdgesFor : List Schema.User -> Response (List UserAuthoredPost)
fetchUserAuthoredPostEdgesFor users =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , where_ = Just (Table.UserAuthoredPost.Where.UserId.in_ (List.map Schema.User.id users))
        , limit = Nothing
        }
        |> GraphQL.Response.fromDatabaseQuery


fetchPostsFor : List Schema.User -> List UserAuthoredPost -> Response (List Schema.User)
fetchPostsFor users edges =
    Table.Posts.findAll
        { select = Schema.Post.selectAll
        , limit = Nothing
        , where_ = Just (Table.Posts.Where.Id.in_ (List.map .postId edges))
        }
        |> GraphQL.Response.fromDatabaseQuery
        |> GraphQL.Response.map (fillInPostsForAuthors users edges)


fillInPostsForAuthors :
    List Schema.User
    -> List UserAuthoredPost
    -> List Schema.Post
    -> List Schema.User
fillInPostsForAuthors users edges posts =
    List.map (updateUserWithPosts edges posts) users


updateUserWithPosts : List UserAuthoredPost -> List Schema.Post -> Schema.User -> Schema.User
updateUserWithPosts edges posts (Schema.User user) =
    let
        edgesMatchingThisUser : List UserAuthoredPost
        edgesMatchingThisUser =
            List.filter (\edge -> edge.userId == user.id) edges

        postsMatchingThisUser : List Schema.Post
        postsMatchingThisUser =
            List.filterMap findPostForEdge edgesMatchingThisUser

        findPostForEdge : UserAuthoredPost -> Maybe Schema.Post
        findPostForEdge edge =
            List.Extra.find (\(Schema.Post post) -> post.id == edge.postId) posts
    in
    Schema.User { user | posts = postsMatchingThisUser }
