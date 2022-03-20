module Table.People exposing
    ( findOne, findAll
    , insertOne
    , updateOne
    )

{-|

@docs findOne, findAll
@docs insertOne
@docs updateOne

-}

import Database.Query
import Database.Where
import Table.People.Column
import Table.People.Select
import Table.People.Value


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
    { values : List Table.People.Value.Value
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


updateOne :
    { set : List Table.People.Value.Value
    , where_ : Maybe (Database.Where.Clause Table.People.Column.Column)
    , returning : Table.People.Select.Decoder value
    }
    -> Database.Query.Query Table.People.Column.Column (Maybe value)
updateOne options =
    Database.Query.updateOne
        { tableName = tableName
        , toColumnName = Table.People.Column.toString
        , set = options.set
        , where_ = options.where_
        , returning = options.returning
        }


deleteOne :
    { where_ : Maybe (Database.Where.Clause Table.People.Column.Column)
    , returning : Table.People.Select.Decoder value
    }
    -> Database.Query.Query Table.People.Column.Column (Maybe value)
deleteOne options =
    Database.Query.deleteOne
        { tableName = tableName
        , toColumnName = Table.People.Column.toString
        , where_ = options.where_
        , returning = options.returning
        }


tableName : String
tableName =
    "people"
