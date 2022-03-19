module Database.Insert exposing
    ( Value
    , int
    , nullableText
    , text
    , toSql
    )


type Value column
    = TextValue column String
    | IntValue column Int
    | NullableTextValue column (Maybe String)


text : column -> String -> Value column
text =
    TextValue


int : column -> Int -> Value column
int =
    IntValue


nullableText : column -> Maybe String -> Value column
nullableText =
    NullableTextValue


toSql : (column -> String) -> List (Value column) -> String
toSql toColumnName values =
    let
        columns : String
        columns =
            values
                |> List.map toColumn
                |> List.map toColumnName
                |> String.join ", "

        values_ : String
        values_ =
            values
                |> List.map toValueString
                |> String.join ", "
    in
    "({{columns}}) VALUES ({{values}})"
        |> String.replace "{{columns}}" columns
        |> String.replace "{{values}}" values_


toColumn : Value column -> column
toColumn value =
    case value of
        TextValue c _ ->
            c

        IntValue c _ ->
            c

        NullableTextValue c _ ->
            c


toValueString : Value column -> String
toValueString value =
    case value of
        TextValue _ v ->
            "\"" ++ v ++ "\""

        IntValue _ v ->
            String.fromInt v

        NullableTextValue _ (Just v) ->
            "\"" ++ v ++ "\""

        NullableTextValue _ Nothing ->
            "NULL"
