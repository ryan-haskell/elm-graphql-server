module Table.Users.Where.Id exposing (equals)

import Database.Where
import Table.Users.Column


equals : Int -> Database.Where.Clause Table.Users.Column.Column
equals value =
    Database.Where.equalsInt
        (Table.Users.Column.toString Table.Users.Column.id)
        value
