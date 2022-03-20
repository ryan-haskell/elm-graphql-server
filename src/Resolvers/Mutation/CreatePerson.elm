module Resolvers.Mutation.CreatePerson exposing (argumentsDecoder, resolver)

import GraphQL.Response
import Json.Decode
import Schema.Person exposing (Person)
import Table.People
import Table.People.Select
import Table.People.Value


type alias Arguments =
    { name : String
    , email : Maybe String
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map2 Arguments
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "email" Json.Decode.string))


resolver : () -> Arguments -> GraphQL.Response.Response Person
resolver _ args =
    Table.People.insertOne
        { values =
            [ Table.People.Value.name args.name
            , Table.People.Value.email args.email
            ]
        , returning =
            Table.People.Select.new Person
                |> Table.People.Select.id
                |> Table.People.Select.name
                |> Table.People.Select.email
        }
        |> GraphQL.Response.fromDatabaseQuery
