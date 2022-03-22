module Table.Users.Value exposing (Value, avatarUrl, username)

import Database.Value
import Table.Users.Column


type alias Value =
    Database.Value.Value Table.Users.Column.Column


username : String -> Value
username value =
    Database.Value.text Table.Users.Column.username value


avatarUrl : Maybe String -> Value
avatarUrl value =
    Database.Value.nullableText Table.Users.Column.avatarUrl value
