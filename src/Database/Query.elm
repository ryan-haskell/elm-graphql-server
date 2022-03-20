module Database.Query exposing (Query, findAll, findOne, insertOne, toDecoder, toSql, updateOne)

import Database.Select
import Database.Value
import Database.Where
import Json.Decode


type Query column value
    = Find
        { tableName : String
        , where_ : Maybe (Database.Where.Clause column)
        , select : Database.Select.Decoder column value
        , limit : Maybe Int
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


findOne :
    { tableName : String
    , where_ : Maybe (Database.Where.Clause column)
    , select : Database.Select.Decoder column value
    }
    -> Query column (Maybe value)
findOne options =
    Find
        { tableName = options.tableName
        , where_ = options.where_
        , select = Database.Select.mapDecoder (Json.Decode.index 0 << Json.Decode.maybe) options.select
        , limit = Just 1
        }


findAll :
    { tableName : String
    , select : Database.Select.Decoder column value
    , where_ : Maybe (Database.Where.Clause column)
    , limit : Maybe Int
    }
    -> Query column (List value)
findAll options =
    Find
        { tableName = options.tableName
        , where_ = options.where_
        , select = Database.Select.mapDecoder Json.Decode.list options.select
        , limit = options.limit
        }


insertOne :
    { tableName : String
    , toColumnName : column -> String
    , values : List (Database.Value.Value column)
    , returning : Database.Select.Decoder column value
    }
    -> Query column value
insertOne options =
    Insert { options | returning = Database.Select.mapDecoder (Json.Decode.index 0) options.returning }


updateOne :
    { tableName : String
    , toColumnName : column -> String
    , set : List (Database.Value.Value column)
    , where_ : Maybe (Database.Where.Clause column)
    , returning : Database.Select.Decoder column value
    }
    -> Query column (Maybe value)
updateOne options =
    Update
        { tableName = options.tableName
        , toColumnName = options.toColumnName
        , set = options.set
        , where_ = options.where_
        , returning = Database.Select.mapDecoder (Json.Decode.index 0 << Json.Decode.maybe) options.returning
        }


toSql : Query column value -> String
toSql query =
    case query of
        Find options ->
            let
                template : String
                template =
                    case ( options.where_, options.limit ) of
                        ( Just whereClause, Just limit ) ->
                            "SELECT {{select}} FROM {{tableName}} WHERE {{whereClause}} LIMIT {{limit}}"
                                |> String.replace "{{whereClause}}" (Database.Where.toSql whereClause)
                                |> String.replace "{{limit}}" (String.fromInt limit)

                        ( Nothing, Just limit ) ->
                            "SELECT {{select}} FROM {{tableName}} LIMIT {{limit}}"
                                |> String.replace "{{limit}}" (String.fromInt limit)

                        ( Just whereClause, Nothing ) ->
                            "SELECT {{select}} FROM {{tableName}} WHERE {{whereClause}}"
                                |> String.replace "{{whereClause}}" (Database.Where.toSql whereClause)

                        ( Nothing, Nothing ) ->
                            "SELECT {{select}} FROM {{tableName}}"
            in
            template
                |> String.replace "{{tableName}}" options.tableName
                |> String.replace "{{select}}" (Database.Select.toSql options.select)

        Insert options ->
            "INSERT INTO {{tableName}} {{data}} RETURNING {{returning}}"
                |> String.replace "{{tableName}}" options.tableName
                |> String.replace "{{data}}" (Database.Value.toInsertSql options.toColumnName options.values)
                |> String.replace "{{returning}}" (Database.Select.toSql options.returning)

        Update options ->
            case options.where_ of
                Nothing ->
                    "UPDATE {{tableName}} SET {{set}} RETURNING {{returning}}"
                        |> String.replace "{{tableName}}" options.tableName
                        |> String.replace "{{set}}" (Database.Value.toUpdateSql options.toColumnName options.set)
                        |> String.replace "{{returning}}" (Database.Select.toSql options.returning)

                Just where_ ->
                    "UPDATE {{tableName}} SET {{set}} WHERE {{where}} RETURNING {{returning}}"
                        |> String.replace "{{tableName}}" options.tableName
                        |> String.replace "{{set}}" (Database.Value.toUpdateSql options.toColumnName options.set)
                        |> String.replace "{{where}}" (Database.Where.toSql where_)
                        |> String.replace "{{returning}}" (Database.Select.toSql options.returning)


toDecoder : Query column value -> Json.Decode.Decoder value
toDecoder query =
    case query of
        Find options ->
            Database.Select.toJsonDecoder options.select

        Insert options ->
            Database.Select.toJsonDecoder options.returning

        Update options ->
            Database.Select.toJsonDecoder options.returning
