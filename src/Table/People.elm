module Table.People exposing
    ( findOne, findAll
    , insertOne
    )

{-|

@docs findOne, findAll
@docs insertOne

-}

import Database.Query
import Database.Where
import Table.People.Column
import Table.People.Insert
import Table.People.Select


type alias Column =
    Table.People.Column.Column


findOne :
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.People.Select.Decoder value
    }
    -> Database.Query.Query Column (Maybe value)
findOne options =
    Database.Query.findOne
        { tableName = tableName
        , where_ = options.where_
        , select = options.select
        }


findAll :
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.People.Select.Decoder value
    , limit : Maybe Int
    }
    -> Database.Query.Query Column (List value)
findAll options =
    Database.Query.findAll
        { tableName = tableName
        , where_ = options.where_
        , select = options.select
        , limit = options.limit
        }


insertOne :
    { values : List Table.People.Insert.Value
    , returning : Table.People.Select.Decoder value
    }
    -> Database.Query.Query Table.People.Column.Column value
insertOne options =
    Database.Query.insertOne
        { tableName = tableName
        , toColumnName = Table.People.Column.toString
        , values = options.values
        , returning = options.returning
        }


tableName : String
tableName =
    "people"
