module Database.Where exposing (Clause, equalsInt, equalsString, inIntList, toSql)

import Database.Utils


type Clause column
    = EqualsInt String Int
    | EqualsString String String
    | InIntList String (List Int)


equalsInt : String -> Int -> Clause column
equalsInt =
    EqualsInt


equalsString : String -> String -> Clause column
equalsString =
    EqualsString


inIntList : String -> List Int -> Clause column
inIntList =
    InIntList


toSql : Clause column -> String
toSql clause =
    case clause of
        EqualsInt left right ->
            left ++ " = " ++ String.fromInt right

        EqualsString left right ->
            left ++ " = " ++ Database.Utils.wrapStringValue right

        InIntList left right ->
            left ++ " IN " ++ Database.Utils.wrapListValue String.fromInt right
