module Table.Users.Select exposing
    ( Decoder, new, map
    , id, username, avatarUrl
    )

{-|

@docs Decoder, new, map
@docs id, username, avatarUrl

-}

import Database.Select
import Json.Decode
import Table.Users.Column


type alias Decoder value =
    Database.Select.Decoder Table.Users.Column.Column value


new : value -> Decoder value
new value =
    Database.Select.new
        Table.Users.Column.toColumnName
        value


map : (a -> b) -> Decoder a -> Decoder b
map =
    Database.Select.map


id : Decoder (Int -> value) -> Decoder value
id decoder =
    Database.Select.with Table.Users.Column.id
        Json.Decode.int
        decoder


username : Decoder (String -> value) -> Decoder value
username decoder =
    Database.Select.with Table.Users.Column.username
        Json.Decode.string
        decoder


avatarUrl : Decoder (Maybe String -> value) -> Decoder value
avatarUrl decoder =
    Database.Select.with Table.Users.Column.avatarUrl
        (Json.Decode.maybe Json.Decode.string)
        decoder
