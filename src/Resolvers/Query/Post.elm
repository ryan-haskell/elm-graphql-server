module Resolvers.Query.Post exposing (argumentsDecoder, resolver)

import GraphQL.Response exposing (Response)
import Json.Decode
import Schema.Post exposing (Post)
import Table.Posts
import Table.Posts.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : () -> Arguments -> Response (Maybe Post)
resolver _ args =
    Table.Posts.findOne
        { where_ = Just (Table.Posts.Where.Id.equals args.id)
        , select = Schema.Post.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
