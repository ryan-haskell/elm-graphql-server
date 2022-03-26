module Database.Query exposing (Query, deleteOne, findAll, findOne, insertOne, toDecoder, toSql, updateOne)

import Database.Order
import Database.Select
import Database.Value
import Database.Where
import Json.Decode


type Query column value
    = Select
        { tableName : String
        , toColumnName : column -> String
        , select : Database.Select.Decoder column value
        , where_ : Maybe (Database.Where.Clause column)
        , orderBy : Maybe (Database.Order.Order column)
        , limit : Maybe Int
        , offset : Maybe Int
        }
    | Insert
        { tableName : String
        , toColumnName : column -> String
        , values : List (Database.Value.Value column)
        , returning : Database.Select.Decoder column value
        }
    | Update
        { tableName : String
        , toColumnName : column -> String
        , set : List (Database.Value.Value column)
        , where_ : Maybe (Database.Where.Clause column)
        , returning : Database.Select.Decoder column value
        }
    | Delete
        { tableName : String
        , toColumnName : column -> String
        , where_ : Maybe (Database.Where.Clause column)
        , returning : Database.Select.Decoder column value
        }


findOne :
    { tableName : String
    , toColumnName : column -> String
    }
    ->
        { select : Database.Select.Decoder column value
        , where_ : Maybe (Database.Where.Clause column)
        }
    -> Query column (Maybe value)
findOne config options =
    Select
        { tableName = config.tableName
        , toColumnName = config.toColumnName
        , where_ = options.where_
        , select = Database.Select.mapDecoder grabFirstMaybeItemInList options.select
        , limit = Just 1
        , offset = Nothing
        , orderBy = Nothing
        }


findAll :
    { tableName : String
    , toColumnName : column -> String
    }
    ->
        { select : Database.Select.Decoder column value
        , where_ : Maybe (Database.Where.Clause column)
        , orderBy : Maybe (Database.Order.Order column)
        , limit : Maybe Int
        , offset : Maybe Int
        }
    -> Query column (List value)
findAll config options =
    Select
        { tableName = config.tableName
        , toColumnName = config.toColumnName
        , where_ = options.where_
        , select = Database.Select.mapDecoder Json.Decode.list options.select
        , limit = options.limit
        , offset = options.offset
        , orderBy = options.orderBy
        }


insertOne :
    { tableName : String
    , toColumnName : column -> String
    }
    ->
        { values : List (Database.Value.Value column)
        , returning : Database.Select.Decoder column value
        }
    -> Query column value
insertOne config options =
    Insert
        { tableName = config.tableName
        , toColumnName = config.toColumnName
        , values = options.values
        , returning = Database.Select.mapDecoder grabFirstItemInList options.returning
        }


updateOne :
    { tableName : String
    , toColumnName : column -> String
    }
    ->
        { set : List (Database.Value.Value column)
        , where_ : Maybe (Database.Where.Clause column)
        , returning : Database.Select.Decoder column value
        }
    -> Query column (Maybe value)
updateOne config options =
    Update
        { tableName = config.tableName
        , toColumnName = config.toColumnName
        , set = options.set
        , where_ = options.where_
        , returning = Database.Select.mapDecoder grabFirstMaybeItemInList options.returning
        }


deleteOne :
    { tableName : String
    , toColumnName : column -> String
    }
    ->
        { where_ : Maybe (Database.Where.Clause column)
        , returning : Database.Select.Decoder column value
        }
    -> Query column (Maybe value)
deleteOne config options =
    Delete
        { tableName = config.tableName
        , toColumnName = config.toColumnName
        , where_ = options.where_
        , returning = Database.Select.mapDecoder grabFirstMaybeItemInList options.returning
        }


toSql : Query column value -> String
toSql query =
    case query of
        Select options ->
            let
                selectSql : String
                selectSql =
                    "SELECT " ++ Database.Select.toSql options.select

                fromSql : String
                fromSql =
                    "FROM " ++ options.tableName

                toOrderBySql : Database.Order.Order column -> String
                toOrderBySql =
                    Database.Order.toSql options.toColumnName

                toWhereSql : Database.Where.Clause column -> String
                toWhereSql where_ =
                    "WHERE " ++ Database.Where.toSql where_

                toLimitSql : Int -> String
                toLimitSql limit =
                    "LIMIT " ++ String.fromInt limit

                toOffsetSql : Int -> String
                toOffsetSql offset =
                    "OFFSET " ++ String.fromInt offset
            in
            List.filterMap identity
                [ Just selectSql
                , Just fromSql
                , Maybe.map toWhereSql options.where_
                , Maybe.map toOrderBySql options.orderBy
                , Maybe.map toLimitSql options.limit
                , Maybe.map toOffsetSql options.offset
                ]
                |> String.join " "

        Insert options ->
            if List.isEmpty options.values then
                "SELECT NULL"

            else
                "INSERT INTO {{tableName}} {{data}} RETURNING {{returning}}"
                    |> String.replace "{{tableName}}" options.tableName
                    |> String.replace "{{data}}" (Database.Value.toInsertSql options.toColumnName options.values)
                    |> String.replace "{{returning}}" (Database.Select.toSql options.returning)

        Update options ->
            case options.where_ of
                Nothing ->
                    if List.isEmpty options.set then
                        "SELECT NULL"

                    else
                        "UPDATE {{tableName}} SET {{set}} RETURNING {{returning}}"
                            |> String.replace "{{tableName}}" options.tableName
                            |> String.replace "{{set}}" (Database.Value.toUpdateSql options.toColumnName options.set)
                            |> String.replace "{{returning}}" (Database.Select.toSql options.returning)

                Just where_ ->
                    if List.isEmpty options.set then
                        "SELECT {{returning}} FROM {{tableName}} WHERE {{where}}"
                            |> String.replace "{{tableName}}" options.tableName
                            |> String.replace "{{where}}" (Database.Where.toSql where_)
                            |> String.replace "{{returning}}" (Database.Select.toSql options.returning)

                    else
                        "UPDATE {{tableName}} SET {{set}} WHERE {{where}} RETURNING {{returning}}"
                            |> String.replace "{{tableName}}" options.tableName
                            |> String.replace "{{set}}" (Database.Value.toUpdateSql options.toColumnName options.set)
                            |> String.replace "{{where}}" (Database.Where.toSql where_)
                            |> String.replace "{{returning}}" (Database.Select.toSql options.returning)

        Delete options ->
            case options.where_ of
                Nothing ->
                    "DELETE FROM {{tableName}} RETURNING {{returning}}"
                        |> String.replace "{{tableName}}" options.tableName
                        |> String.replace "{{returning}}" (Database.Select.toSql options.returning)

                Just where_ ->
                    "DELETE FROM {{tableName}} WHERE {{where}} RETURNING {{returning}}"
                        |> String.replace "{{tableName}}" options.tableName
                        |> String.replace "{{where}}" (Database.Where.toSql where_)
                        |> String.replace "{{returning}}" (Database.Select.toSql options.returning)


toDecoder : Query column value -> Json.Decode.Decoder value
toDecoder query =
    case query of
        Select options ->
            Database.Select.toJsonDecoder options.select

        Insert options ->
            Database.Select.toJsonDecoder options.returning

        Update options ->
            Database.Select.toJsonDecoder options.returning

        Delete options ->
            Database.Select.toJsonDecoder options.returning



-- INTERNALS


grabFirstItemInList : Json.Decode.Decoder a -> Json.Decode.Decoder a
grabFirstItemInList decoder =
    Json.Decode.index 0 decoder


grabFirstMaybeItemInList : Json.Decode.Decoder a -> Json.Decode.Decoder (Maybe a)
grabFirstMaybeItemInList decoder =
    Json.Decode.maybe (Json.Decode.index 0 decoder)
