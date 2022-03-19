module Resolvers.Query.Person exposing (argumentsDecoder, resolver)

import Database.Where
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Schema.Person exposing (Person)
import Table.People
import Table.People.Select
import Table.People.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : () -> Arguments -> Response (Maybe Person)
resolver parent args =
    Table.People.findOne
        { where_ = Just (Table.People.Where.Id.equals args.id)
        , select =
            Table.People.Select.new Person
                |> Table.People.Select.id
                |> Table.People.Select.name
                |> Table.People.Select.email
        }
        |> GraphQL.Response.fromDatabaseQuery
