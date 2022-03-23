module Database.Value exposing
    ( Value
    , int
    , json
    , nullableText
    , text
    , toInsertSql
    , toUpdateSql
    )

import Database.Utils
import Json.Encode


type Value column
    = TextValue column String
    | IntValue column Int
    | JsonValue column Json.Encode.Value
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


json : column -> (value -> Json.Encode.Value) -> value -> Value column
json column toJson value =
    JsonValue column (toJson value)


toInsertSql : (column -> String) -> List (Value column) -> String
toInsertSql toColumnName values =
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


toUpdateSql : (column -> String) -> List (Value column) -> String
toUpdateSql toColumnName values =
    let
        toEquation : Value column -> String
        toEquation value =
            (toColumn >> toColumnName) value ++ " = " ++ toValueString value
    in
    values
        |> List.map toEquation
        |> String.join ", "


toColumn : Value column -> column
toColumn value =
    case value of
        TextValue c _ ->
            c

        IntValue c _ ->
            c

        NullableTextValue c _ ->
            c

        JsonValue c _ ->
            c


toValueString : Value column -> String
toValueString value =
    case value of
        TextValue _ v ->
            Database.Utils.wrapStringValue v

        IntValue _ v ->
            String.fromInt v

        NullableTextValue _ (Just v) ->
            Database.Utils.wrapStringValue v

        NullableTextValue _ Nothing ->
            "NULL"

        JsonValue _ v ->
            Database.Utils.wrapStringValue (Json.Encode.encode 0 v)
