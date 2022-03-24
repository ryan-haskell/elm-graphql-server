module Table.UserAuthoredPost.Where.Id exposing (equals, in_)

import Database.Where
import Database.Where.Int
import Table.UserAuthoredPost.Column


equals : Int -> Database.Where.Clause Table.UserAuthoredPost.Column.Column
equals value =
    Database.Where.Int.equals
        (Table.UserAuthoredPost.Column.toString Table.UserAuthoredPost.Column.id)
        value


in_ : List Int -> Database.Where.Clause Table.UserAuthoredPost.Column.Column
in_ value =
    Database.Where.Int.in_
        (Table.UserAuthoredPost.Column.toString Table.UserAuthoredPost.Column.id)
        value
