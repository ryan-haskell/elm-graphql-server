module Resolvers.Mutation.UpdatePost exposing (argumentsDecoder, resolver)

import GraphQL.Info exposing (Info)
import GraphQL.Response
import Json.Decode
import Optional exposing (Optional)
import Resolvers.Post.Author
import Schema.Post exposing (Post)
import Table.Posts
import Table.Posts.Select
import Table.Posts.Value
import Table.Posts.Where.Id


type alias Arguments =
    { id : Int
    , imageUrls : Optional (List String)
    , caption : Optional String
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map3 Arguments
        (Json.Decode.field "id" Json.Decode.int)
        (Optional.decoder "imageUrls" (Json.Decode.list Json.Decode.string))
        (Optional.decoder "caption" Json.Decode.string)


resolver : Info -> () -> Arguments -> GraphQL.Response.Response (Maybe Post)
resolver info _ args =
    Table.Posts.updateOne
        { set =
            Optional.toList
                [ args.imageUrls |> Optional.map Table.Posts.Value.imageUrls
                , args.caption |> Optional.map Table.Posts.Value.caption
                ]
        , where_ = Just (Table.Posts.Where.Id.equals args.id)
        , returning = Schema.Post.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
