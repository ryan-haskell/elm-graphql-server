module Table.People.Select exposing
    ( Decoder, new
    , id, name, email
    )

{-|

@docs Decoder, new
@docs id, name, email

-}

import Database.Select
import Json.Decode
import Table.People.Column


type alias Decoder value =
    Database.Select.Decoder Table.People.Column.Column value


new : value -> Decoder value
new value =
    Database.Select.new
        Table.People.Column.toString
        value


id : Decoder (Int -> value) -> Decoder value
id decoder =
    Database.Select.with Table.People.Column.id
        Json.Decode.int
        decoder


name : Decoder (String -> value) -> Decoder value
name decoder =
    Database.Select.with Table.People.Column.name
        Json.Decode.string
        decoder


email : Decoder (Maybe String -> value) -> Decoder value
email decoder =
    Database.Select.with Table.People.Column.email
        (Json.Decode.maybe Json.Decode.string)
        decoder
