module Resolvers.Mutation.UpdateUser exposing (argumentsDecoder, resolver)

import GraphQL.Response
import Json.Decode
import Optional exposing (Optional)
import Schema.User exposing (User)
import Table.Users
import Table.Users.Select
import Table.Users.Value
import Table.Users.Where.Id


type alias Arguments =
    { id : Int
    , username : Optional String
    , avatarUrl : Optional (Maybe String)
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map3 Arguments
        (Json.Decode.field "id" Json.Decode.int)
        (Optional.decoder "username" Json.Decode.string)
        (Optional.decoder "avatarUrl" (Json.Decode.maybe Json.Decode.string))


resolver : () -> Arguments -> GraphQL.Response.Response (Maybe User)
resolver _ args =
    Table.Users.updateOne
        { set =
            Optional.toList
                [ args.username |> Optional.map Table.Users.Value.username
                , args.avatarUrl |> Optional.map Table.Users.Value.avatarUrl
                ]
        , where_ = Just (Table.Users.Where.Id.equals args.id)
        , returning = Schema.User.selectAll
        }
        |> GraphQL.Response.fromDatabaseQuery
