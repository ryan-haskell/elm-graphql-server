module Table.Posts.Where.Id exposing (equals, in_)

import Database.Where
import Database.Where.Int
import Table.Posts.Column


equals : Int -> Database.Where.Clause Table.Posts.Column.Column
equals value =
    Database.Where.Int.equals
        (Table.Posts.Column.toColumnName Table.Posts.Column.id)
        value


in_ : List Int -> Database.Where.Clause Table.Posts.Column.Column
in_ value =
    Database.Where.Int.in_
        (Table.Posts.Column.toColumnName Table.Posts.Column.id)
        value
