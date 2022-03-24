module Resolvers.Query.Edges.UserAuthoredPost exposing (fetchAuthorsForList)

import GraphQL.Response exposing (Response)
import Schema.Post exposing (Post)
import Schema.User exposing (User)
import Schema.UserAuthoredPost exposing (UserAuthoredPost)
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Where.Id
import Table.Users
import Table.Users.Where.Id


fetchAuthorsForList : List Post -> Response (List Post)
fetchAuthorsForList posts =
    fetchUserAuthoredPostEdges posts
        |> GraphQL.Response.andThen (fetchAuthorsFor posts)


fetchUserAuthoredPostEdges : List Post -> Response (List UserAuthoredPost)
fetchUserAuthoredPostEdges posts =
    Table.UserAuthoredPost.findAll
        { select = Schema.UserAuthoredPost.selectAll
        , limit = Nothing
        , where_ = Just (Table.UserAuthoredPost.Where.Id.in_ (List.map .id posts))
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
        matchingEdges : List UserAuthoredPost
        matchingEdges =
            List.filter (\edge -> edge.postId == post.id) edges

        matchingUsers =
            matchingEdges
                |> List.filterMap
                    (\edge ->
                        case List.filter (\user -> user.id == edge.userId) users of
                            [] ->
                                Nothing

                            user :: _ ->
                                Just user
                    )
    in
    { post | author = List.head matchingUsers }
