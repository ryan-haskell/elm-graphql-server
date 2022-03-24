module Table.Users.Where.Id exposing (equals, in_)

import Database.Where
import Database.Where.Int
import Table.Users.Column


equals : Int -> Database.Where.Clause Table.Users.Column.Column
equals value =
    Database.Where.Int.equals
        (Table.Users.Column.toColumnName Table.Users.Column.id)
        value


in_ : List Int -> Database.Where.Clause Table.Users.Column.Column
in_ value =
    Database.Where.Int.in_
        (Table.Users.Column.toColumnName Table.Users.Column.id)
        value
