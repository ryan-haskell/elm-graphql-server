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
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.Posts.Select.Decoder value
    }
    -> Query (Maybe value)
findOne =
    Database.Query.findOne
        { tableName = tableName
        }


findAll :
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.Posts.Select.Decoder value
    , limit : Maybe Int
    }
    -> Query (List value)
findAll =
    Database.Query.findAll
        { tableName = tableName
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
