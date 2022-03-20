module Resolvers.Mutation.DeletePerson exposing (argumentsDecoder, resolver)

import GraphQL.Response
import Json.Decode
import Schema.Person exposing (Person)
import Table.People
import Table.People.Select
import Table.People.Value
import Table.People.Where.Id


type alias Arguments =
    { id : Int
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map Arguments
        (Json.Decode.field "id" Json.Decode.int)


resolver : () -> Arguments -> GraphQL.Response.Response (Maybe Person)
resolver _ args =
    Table.People.deleteOne
        { where_ = Just (Table.People.Where.Id.equals args.id)
        , returning =
            Table.People.Select.new Person
                |> Table.People.Select.id
                |> Table.People.Select.name
                |> Table.People.Select.email
        }
        |> GraphQL.Response.fromDatabaseQuery
