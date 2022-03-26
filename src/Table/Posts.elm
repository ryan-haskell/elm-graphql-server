module Table.Posts exposing
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
import Table.Posts.Column
import Table.Posts.Select
import Table.Posts.Value


type alias Column =
    Table.Posts.Column.Column


type alias Query value =
    Database.Query.Query Column value


tableName : String
tableName =
    "posts"


findOne :
    { select : Table.Posts.Select.Decoder value
    , where_ : Maybe (Database.Where.Clause Column)
    }
    -> Query (Maybe value)
findOne =
    Database.Query.findOne
        { tableName = tableName
        , toColumnName = Table.Posts.Column.toColumnName
        }


findAll :
    { select : Table.Posts.Select.Decoder value
    , where_ : Maybe (Database.Where.Clause Column)
    , orderBy : Maybe (Database.Order.Order Column)
    , limit : Maybe Int
    , offset : Maybe Int
    }
    -> Query (List value)
findAll =
    Database.Query.findAll
        { tableName = tableName
        , toColumnName = Table.Posts.Column.toColumnName
        }


insertOne :
    { values : List Table.Posts.Value.Value
    , returning : Table.Posts.Select.Decoder value
    }
    -> Query value
insertOne =
    Database.Query.insertOne
        { tableName = tableName
        , toColumnName = Table.Posts.Column.toColumnName
        }


updateOne :
    { set : List Table.Posts.Value.Value
    , where_ : Maybe (Database.Where.Clause Table.Posts.Column.Column)
    , returning : Table.Posts.Select.Decoder value
    }
    -> Query (Maybe value)
updateOne =
    Database.Query.updateOne
        { tableName = tableName
        , toColumnName = Table.Posts.Column.toColumnName
        }


deleteOne :
    { where_ : Maybe (Database.Where.Clause Table.Posts.Column.Column)
    , returning : Table.Posts.Select.Decoder value
    }
    -> Query (Maybe value)
deleteOne =
    Database.Query.deleteOne
        { tableName = tableName
        , toColumnName = Table.Posts.Column.toColumnName
        }
