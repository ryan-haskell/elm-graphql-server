module Table.People.Value exposing (Value, email, name)

import Database.Value
import Table.People.Column


type alias Value =
    Database.Value.Value Table.People.Column.Column


name : String -> Value
name value =
    Database.Value.text Table.People.Column.name value


email : Maybe String -> Value
email value =
    Database.Value.nullableText Table.People.Column.email value
