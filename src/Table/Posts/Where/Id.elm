module Table.Posts.Where.Id exposing (equals)

import Database.Where
import Table.Posts.Column


equals : Int -> Database.Where.Clause Table.Posts.Column.Column
equals value =
    Database.Where.equalsInt
        (Table.Posts.Column.toColumnName Table.Posts.Column.id)
        value
