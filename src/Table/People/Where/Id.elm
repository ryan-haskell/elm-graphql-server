module Table.People.Where.Id exposing (equals)

import Database.Where
import Table.People.Column


equals : Int -> Database.Where.Clause Table.People.Column.Column
equals value =
    Database.Where.equalsInt
        (Table.People.Column.toString Table.People.Column.id)
        value
