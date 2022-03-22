module Table.Users exposing
    ( findOne, findAll
    , insertOne
    , updateOne
    , deleteOne
    )

{-|

@docs findOne, findAll
@docs insertOne
@docs updateOne
@docs deleteOne

-}

import Database.Query
import Database.Where
import Table.Users.Column
import Table.Users.Select
import Table.Users.Value


type alias Column =
    Table.Users.Column.Column


tableName : String
tableName =
    "users"


findOne :
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.Users.Select.Decoder value
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
    , select : Table.Users.Select.Decoder value
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
    { values : List Table.Users.Value.Value
    , returning : Table.Users.Select.Decoder value
    }
    -> Database.Query.Query Table.Users.Column.Column value
insertOne options =
    Database.Query.insertOne
        { tableName = tableName
        , toColumnName = Table.Users.Column.toString
        , values = options.values
        , returning = options.returning
        }


updateOne :
    { set : List Table.Users.Value.Value
    , where_ : Maybe (Database.Where.Clause Table.Users.Column.Column)
    , returning : Table.Users.Select.Decoder value
    }
    -> Database.Query.Query Table.Users.Column.Column (Maybe value)
updateOne options =
    Database.Query.updateOne
        { tableName = tableName
        , toColumnName = Table.Users.Column.toString
        , set = options.set
        , where_ = options.where_
        , returning = options.returning
        }


deleteOne :
    { where_ : Maybe (Database.Where.Clause Table.Users.Column.Column)
    , returning : Table.Users.Select.Decoder value
    }
    -> Database.Query.Query Table.Users.Column.Column (Maybe value)
deleteOne options =
    Database.Query.deleteOne
        { tableName = tableName
        , toColumnName = Table.Users.Column.toString
        , where_ = options.where_
        , returning = options.returning
        }
