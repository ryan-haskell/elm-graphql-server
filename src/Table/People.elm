module Table.People exposing
    ( Column
    , findOne, findAll
    )

{-|

@docs Column
@docs findOne, findAll

-}

import Database.Query
import Database.Where
import Table.People.Column
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


tableName : String
tableName =
    "people"
