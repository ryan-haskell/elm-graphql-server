module Database.Where.Int exposing (equals, in_)

import Database.Where


equals : String -> Int -> Database.Where.Clause column
equals =
    Database.Where.equalsInt


in_ : String -> List Int -> Database.Where.Clause column
in_ =
    Database.Where.inIntList
