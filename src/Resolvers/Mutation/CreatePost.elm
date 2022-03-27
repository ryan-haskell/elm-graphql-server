module Resolvers.Mutation.CreatePost exposing (argumentsDecoder, resolver)

import GraphQL.Context exposing (Context)
import GraphQL.Info exposing (Info)
import GraphQL.Response
import Json.Decode
import Resolvers.Post.Author
import Schema.Post exposing (Post)
import Schema.UserAuthoredPost
import Table.Posts
import Table.Posts.Select
import Table.Posts.Value
import Table.UserAuthoredPost
import Table.UserAuthoredPost.Value
import Table.Users


type alias Arguments =
    { imageUrls : List String
    , caption : String
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map2 Arguments
        (Json.Decode.field "imageUrls" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "caption" Json.Decode.string)


resolver : Info -> Context -> () -> Arguments -> GraphQL.Response.Response Post
resolver info context _ args =
    case context.currentUserId of
        Nothing ->
            GraphQL.Response.err "Must be signed in to create a post."

        Just currentUserId ->
            createPostAndEdge args currentUserId


createPostAndEdge : Arguments -> Int -> GraphQL.Response.Response Post
createPostAndEdge args currentUserId =
    Table.Posts.insertOne
        { values =
            [ Table.Posts.Value.imageUrls args.imageUrls
            , Table.Posts.Value.caption args.caption
            ]
        , returning = Schema.Post.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
        |> GraphQL.Response.andThen (createUserAuthoredPost currentUserId)


createUserAuthoredPost : Int -> Post -> GraphQL.Response.Response Post
createUserAuthoredPost currentUserId post =
    Table.UserAuthoredPost.insertOne
        { values =
            [ Table.UserAuthoredPost.Value.postId (Schema.Post.id post)
            , Table.UserAuthoredPost.Value.userId currentUserId
            ]
        , returning = Schema.UserAuthoredPost.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
        |> GraphQL.Response.map (\_ -> post)
