module Table.People.Insert exposing (Value, email, name)

import Database.Insert
import Table.People.Column


type alias Value =
    Database.Insert.Value Table.People.Column.Column


name : String -> Value
name value =
    Database.Insert.text Table.People.Column.name value


email : Maybe String -> Value
email value =
    Database.Insert.nullableText Table.People.Column.email value
