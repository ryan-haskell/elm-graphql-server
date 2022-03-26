module Table.Users exposing
    ( Query
    , findOne, findAll
    , insertOne
    , updateOne
    , deleteOne
    )

{-|

@docs Query
@docs findOne, findAll
@docs insertOne
@docs updateOne
@docs deleteOne

-}

import Database.Order
import Database.Query
import Database.Where
import Table.Users.Column
import Table.Users.Select
import Table.Users.Value


type alias Column =
    Table.Users.Column.Column


type alias Query value =
    Database.Query.Query Column value


tableName : String
tableName =
    "users"


findOne :
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.Users.Select.Decoder value
    }
    -> Query (Maybe value)
findOne =
    Database.Query.findOne
        { tableName = tableName
        , toColumnName = Table.Users.Column.toColumnName
        }


findAll :
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.Users.Select.Decoder value
    , limit : Maybe Int
    , offset : Maybe Int
    , orderBy : Maybe (Database.Order.Order Column)
    }
    -> Query (List value)
findAll =
    Database.Query.findAll
        { tableName = tableName
        , toColumnName = Table.Users.Column.toColumnName
        }


insertOne :
    { values : List Table.Users.Value.Value
    , returning : Table.Users.Select.Decoder value
    }
    -> Query value
insertOne =
    Database.Query.insertOne
        { tableName = tableName
        , toColumnName = Table.Users.Column.toColumnName
        }


updateOne :
    { set : List Table.Users.Value.Value
    , where_ : Maybe (Database.Where.Clause Table.Users.Column.Column)
    , returning : Table.Users.Select.Decoder value
    }
    -> Query (Maybe value)
updateOne =
    Database.Query.updateOne
        { tableName = tableName
        , toColumnName = Table.Users.Column.toColumnName
        }


deleteOne :
    { where_ : Maybe (Database.Where.Clause Table.Users.Column.Column)
    , returning : Table.Users.Select.Decoder value
    }
    -> Query (Maybe value)
deleteOne =
    Database.Query.deleteOne
        { tableName = tableName
        , toColumnName = Table.Users.Column.toColumnName
        }
