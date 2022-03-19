module Table.People exposing
    ( Column
    , findOne
    )

{-|

@docs Column
@docs id, name, email

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


tableName : String
tableName =
    "people"
