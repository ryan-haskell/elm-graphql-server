module Schema.User exposing (User, decoder, encode, selectAll)

import Json.Decode
import Json.Encode
import Table.Users.Select


type alias User =
    { id : Int
    , username : String
    , avatarUrl : Maybe String
    }


selectAll : Table.Users.Select.Decoder User
selectAll =
    Table.Users.Select.new User
        |> Table.Users.Select.id
        |> Table.Users.Select.username
        |> Table.Users.Select.avatarUrl


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
