module Resolvers.Query.Person exposing (Person, argumentsDecoder, decoder, encode, resolver)

import Database.Where
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Table.People
import Table.People.Select
import Table.People.Where.Id


type alias Person =
    { id : Int
    , name : String
    , email : Maybe String
    }


decoder : Json.Decode.Decoder Person
decoder =
    Json.Decode.map3 Person
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "email" Json.Decode.string))


encode : Person -> Json.Decode.Value
encode person =
    Json.Encode.object
        (List.filterMap identity
            [ Just ( "id", Json.Encode.int person.id )
            , Just ( "name", Json.Encode.string person.name )
            , person.email |> Maybe.map (\email -> ( "email", Json.Encode.string email ))
            ]
        )


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
