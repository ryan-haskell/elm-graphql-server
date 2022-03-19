module Schema.Person exposing (Person, decoder, encode)

import Json.Decode
import Json.Encode


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
