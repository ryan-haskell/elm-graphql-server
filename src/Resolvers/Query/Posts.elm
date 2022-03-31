module Resolvers.Query.Posts exposing (argDecoder, resolver)

import Database.Order
import GraphQL.Response exposing (Response)
import Json.Decode
import Schema.Post exposing (Post)
import Table.Posts
import Table.Posts.Column


type alias Arguments =
    { page : Maybe Int
    }


argDecoder : Json.Decode.Decoder Arguments
argDecoder =
    Json.Decode.map Arguments
        (Json.Decode.maybe (Json.Decode.field "page" Json.Decode.int))


pageSize : Int
pageSize =
    25


resolver : () -> Arguments -> Response (List Post)
resolver _ args =
    let
        page : Int
        page =
            case args.page of
                Just pageFromArgs ->
                    if pageFromArgs > 0 then
                        pageFromArgs

                    else
                        1

                Nothing ->
                    1
    in
    Table.Posts.findAll
        { select = Schema.Post.selectAll
        , where_ = Nothing
        , orderBy = Just (Database.Order.ascending Table.Posts.Column.id)
        , limit = Just pageSize
        , offset = Just (pageSize * (page - 1))
        }
        |> GraphQL.Response.fromDatabaseQuery
