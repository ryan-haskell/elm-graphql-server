module Resolvers.Query.Person exposing (Person, decoder, encode, resolver)

import GraphQL
import Json.Decode as Json
import Json.Encode


type alias Person =
    { name : String
    }


decoder : Json.Decoder Person
decoder =
    Json.map Person
        (Json.field "name" Json.string)


encode : Person -> Json.Value
encode person =
    Json.Encode.object
        [ ( "name", Json.Encode.string person.name )
        ]


resolver : () -> () -> GraphQL.Response Person
resolver parent args =
    Ok
        { name = "Ryan Haskell-Glatz"
        }
