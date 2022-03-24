module Resolvers.Post.Author exposing
    ( resolver
    , include, includeForList, includeForMaybe
    )

{-|

@docs resolver

@docs include, includeForList, includeForMaybe

-}

import GraphQL.Response exposing (Response)
import List.Extra
import Schema.Post exposing (Post)
import Schema.User exposing (User)
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.Id
import Table.UserAuthoredPost.Where.PostId
import Table.Users
import Table.Users.Where.Id


resolver : Post -> () -> Response (Maybe User)
resolver post args =
    GraphQL.Response.ok post.author


include : Post -> Response Post
include post =
    includeForList [ post ]
        |> GraphQL.Response.map (\posts -> List.head posts |> Maybe.withDefault post)


includeForMaybe : Maybe Post -> Response (Maybe Post)
includeForMaybe maybePost =
    case maybePost of
        Just post ->
            include post
                |> GraphQL.Response.map Just

        Nothing ->
            GraphQL.Response.ok Nothing


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
        , where_ = Just (Table.UserAuthoredPost.Where.PostId.in_ (List.map .id posts))
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
updatePostWithMatchingUser edges users post =
    let
        edgesMatchingThisPost : List UserAuthoredPost
        edgesMatchingThisPost =
            List.filter (\edge -> edge.postId == post.id) edges

        usersMatchingThisPost : List User
        usersMatchingThisPost =
            List.filterMap findUserForEdge edgesMatchingThisPost

        findUserForEdge : UserAuthoredPost -> Maybe User
        findUserForEdge edge =
            List.Extra.find (\user -> user.id == edge.userId) users
    in
    { post | author = List.head usersMatchingThisPost }
