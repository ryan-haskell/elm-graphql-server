module Table.UserAuthoredPost.Where.Id exposing (equals)

import Database.Where
import Table.UserAuthoredPost.Column


equals : Int -> Database.Where.Clause Table.UserAuthoredPost.Column.Column
equals value =
    Database.Where.equalsInt
        (Table.UserAuthoredPost.Column.toString Table.UserAuthoredPost.Column.id)
        value
