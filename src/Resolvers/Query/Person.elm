module Resolvers.Query.Person exposing (Person, decoder, encode, resolver)

import GraphQL
import Json.Decode as Json
import Json.Encode
import Scalar.Id


type alias Person =
    { id : Scalar.Id.Id
    , name : String
    , email : Maybe String
    }


decoder : Json.Decoder Person
decoder =
    Json.map3 Person
        (Json.field "id" Scalar.Id.decoder)
        (Json.field "name" Json.string)
        (Json.maybe (Json.field "email" Json.string))


encode : Person -> Json.Value
encode person =
    Json.Encode.object
        (List.filterMap identity
            [ Just ( "id", Scalar.Id.encode person.id )
            , Just ( "name", Json.Encode.string person.name )
            , person.email |> Maybe.map (\email -> ( "email", Json.Encode.string email ))
            ]
        )


resolver : () -> () -> GraphQL.Response Person
resolver parent args =
    Ok
        { id = Scalar.Id.fromString "1"
        , name = "Ryan Haskell-Glatz"
        , email = Nothing
        }
