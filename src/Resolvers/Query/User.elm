module Resolvers.Query.User exposing (argumentsDecoder, resolver)

import Database.Where
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Resolvers.User.Posts
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select
import Table.Users.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : () -> Arguments -> Response (Maybe User)
resolver _ args =
    Table.Users.findOne
        { where_ = Just (Table.Users.Where.Id.equals args.id)
        , select = Schema.User.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
