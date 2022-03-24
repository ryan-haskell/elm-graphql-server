module Schema.User exposing
    ( User, selectAll
    , decoder, encode
    )

{-|

@docs User, selectAll
@docs decoder, encode

-}

import Json.Decode
import Json.Encode
import Schema
import Table.Users.Select


type alias User =
    Schema.User


selectAll : Table.Users.Select.Decoder Schema.User
selectAll =
    Schema.user.selectAll


decoder : Json.Decode.Decoder Schema.User
decoder =
    Schema.user.decoder


encode : Schema.User -> Json.Encode.Value
encode =
    Schema.user.encode
