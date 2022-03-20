module Database.Where exposing (Clause, equalsInt, equalsString, toSql)

import Database.Utils


type Clause column
    = EqualsInt String Int
    | EqualsString String String


equalsInt : String -> Int -> Clause column
equalsInt =
    EqualsInt


equalsString : String -> String -> Clause column
equalsString =
    EqualsString


toSql : Clause column -> String
toSql clause =
    case clause of
        EqualsInt left right ->
            left ++ " = " ++ String.fromInt right

        EqualsString left right ->
            left ++ " = " ++ Database.Utils.wrapStringValue right
