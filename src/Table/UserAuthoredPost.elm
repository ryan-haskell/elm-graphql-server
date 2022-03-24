module Table.UserAuthoredPost exposing
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
import Table.UserAuthoredPost.Column
import Table.UserAuthoredPost.Select
import Table.UserAuthoredPost.Value


type alias Column =
    Table.UserAuthoredPost.Column.Column


type alias Query value =
    Database.Query.Query Column value


tableName : String
tableName =
    "user_authored_post"


findOne :
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.UserAuthoredPost.Select.Decoder value
    }
    -> Query (Maybe value)
findOne =
    Database.Query.findOne
        { tableName = tableName
        }


findAll :
    { where_ : Maybe (Database.Where.Clause Column)
    , select : Table.UserAuthoredPost.Select.Decoder value
    , limit : Maybe Int
    }
    -> Query (List value)
findAll =
    Database.Query.findAll
        { tableName = tableName
        }


insertOne :
    { values : List Table.UserAuthoredPost.Value.Value
    , returning : Table.UserAuthoredPost.Select.Decoder value
    }
    -> Query value
insertOne =
    Database.Query.insertOne
        { tableName = tableName
        , toColumnName = Table.UserAuthoredPost.Column.toColumnName
        }


updateOne :
    { set : List Table.UserAuthoredPost.Value.Value
    , where_ : Maybe (Database.Where.Clause Table.UserAuthoredPost.Column.Column)
    , returning : Table.UserAuthoredPost.Select.Decoder value
    }
    -> Query (Maybe value)
updateOne =
    Database.Query.updateOne
        { tableName = tableName
        , toColumnName = Table.UserAuthoredPost.Column.toColumnName
        }


deleteOne :
    { where_ : Maybe (Database.Where.Clause Table.UserAuthoredPost.Column.Column)
    , returning : Table.UserAuthoredPost.Select.Decoder value
    }
    -> Query (Maybe value)
deleteOne =
    Database.Query.deleteOne
        { tableName = tableName
        , toColumnName = Table.UserAuthoredPost.Column.toColumnName
        }
