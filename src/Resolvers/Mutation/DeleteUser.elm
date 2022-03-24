module Resolvers.Mutation.DeleteUser exposing (argumentsDecoder, resolver)

import GraphQL.Response
import Json.Decode
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select
import Table.Users.Value
import Table.Users.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : () -> Arguments -> GraphQL.Response.Response (Maybe User)
resolver _ args =
    Table.Users.deleteOne
        { where_ = Just (Table.Users.Where.Id.equals args.id)
        , returning = Schema.User.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
