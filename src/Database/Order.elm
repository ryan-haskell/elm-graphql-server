module Database.Order exposing
    ( Order, ascending, descending
    , toSql
    )

{-|

@docs Order, ascending, descending
@docs toSql

-}


type Order column
    = Ascending column
    | Descending column


ascending : column -> Order column
ascending =
    Ascending


descending : column -> Order column
descending =
    Descending


toSql : (column -> String) -> Order column -> String
toSql toColumnName order =
    let
        ( column, direction ) =
            case order of
                Ascending col ->
                    ( col, "ASC" )

                Descending col ->
                    ( col, "DESC" )
    in
    "ORDER BY {{name}} {{direction}}"
        |> String.replace "{{name}}" (toColumnName column)
        |> String.replace "{{direction}}" direction
