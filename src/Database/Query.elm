module Database.Query exposing (Query, findOne, toDecoder, toSql)

import Database.Select
import Database.Where
import Json.Decode


type Query column value
    = FindOne
        { tableName : String
        , where_ : Maybe (Database.Where.Clause column)
        , select : Database.Select.Decoder column value
        }


findOne :
    { tableName : String
    , where_ : Maybe (Database.Where.Clause column)
    , select : Database.Select.Decoder column value
    }
    -> Query column (Maybe value)
findOne options =
    FindOne
        { tableName = options.tableName
        , where_ = options.where_
        , select = Database.Select.mapDecoder (Json.Decode.index 0 << Json.Decode.maybe) options.select
        }


toSql : Query column value -> String
toSql query =
    case query of
        FindOne options ->
            case options.where_ of
                Just whereClause ->
                    "SELECT {{columns}} FROM {{tableName}} WHERE {{whereClause}}"
                        |> String.replace "{{tableName}}" options.tableName
                        |> String.replace "{{columns}}" (Database.Select.toSql options.select)
                        |> String.replace "{{whereClause}}" (Database.Where.toSql whereClause)

                Nothing ->
                    "SELECT {{columns}} FROM {{tableName}}"
                        |> String.replace "{{tableName}}" options.tableName
                        |> String.replace "{{columns}}" (Database.Select.toSql options.select)


toDecoder : Query column value -> Json.Decode.Decoder value
toDecoder query =
    case query of
        FindOne options ->
            Database.Select.toJsonDecoder options.select
