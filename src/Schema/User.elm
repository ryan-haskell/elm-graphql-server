module Schema.User exposing (User, decoder, encode)

import Json.Decode
import Json.Encode


type alias User =
    { id : Int
    , username : String
    , avatarUrl : Maybe String
    }


decoder : Json.Decode.Decoder User
decoder =
    Json.Decode.map3 User
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "avatarUrl" Json.Decode.string))


encode : User -> Json.Decode.Value
encode user =
    Json.Encode.object
        (List.filterMap identity
            [ Just ( "id", Json.Encode.int user.id )
            , Just ( "username", Json.Encode.string user.username )
            , user.avatarUrl |> Maybe.map (\avatarUrl -> ( "avatarUrl", Json.Encode.string avatarUrl ))
            ]
        )
