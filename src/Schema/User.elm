module Schema.User exposing
    ( User, selectAll
    , decoder, encode
    , id
    )

{-|

@docs User, selectAll
@docs decoder, encode

@docs id

-}

import Json.Decode
import Json.Encode
import Schema
import Table.Users.Select


type alias User =
    Schema.User


id : Schema.User -> Int
id (Schema.User user) =
    user.id


selectAll : Table.Users.Select.Decoder Schema.User
selectAll =
    Schema.user.selectAll


decoder : Json.Decode.Decoder Schema.User
decoder =
    Schema.user.decoder


encode : Schema.User -> Json.Encode.Value
encode =
    Schema.user.encode
