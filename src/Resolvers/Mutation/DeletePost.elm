module Resolvers.Mutation.DeletePost exposing (argumentsDecoder, resolver)

import GraphQL.Info exposing (Info)
import GraphQL.Response
import Json.Decode
import Resolvers.Post.Author
import Schema.Post exposing (Post)
import Table.Posts
import Table.Posts.Select
import Table.Posts.Value
import Table.Posts.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : Info -> () -> Arguments -> GraphQL.Response.Response (Maybe Post)
resolver info _ args =
    Table.Posts.deleteOne
        { where_ = Just (Table.Posts.Where.Id.equals args.id)
        , returning = Schema.Post.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
