module Resolvers.Mutation.UpdatePerson exposing (argumentsDecoder, resolver)

import GraphQL.Response
import Json.Decode
import Optional exposing (Optional)
import Schema.Person exposing (Person)
import Table.People
import Table.People.Select
import Table.People.Value
import Table.People.Where.Id


type alias Arguments =
    { id : Int
    , name : Optional String
    , email : Optional (Maybe String)
    }


argumentsDecoder : Json.Decode.Decoder Arguments
argumentsDecoder =
    Json.Decode.map3 Arguments
        (Json.Decode.field "id" Json.Decode.int)
        (Optional.decoder "name" Json.Decode.string)
        (Optional.decoder "email" (Json.Decode.maybe Json.Decode.string))


resolver : () -> Arguments -> GraphQL.Response.Response (Maybe Person)
resolver _ args =
    Table.People.updateOne
        { set =
            Optional.toList
                [ args.name |> Optional.map Table.People.Value.name
                , args.email |> Optional.map Table.People.Value.email
                ]
        , where_ = Just (Table.People.Where.Id.equals args.id)
        , returning =
            Table.People.Select.new Person
                |> Table.People.Select.id
                |> Table.People.Select.name
                |> Table.People.Select.email
        }
        |> GraphQL.Response.fromDatabaseQuery
