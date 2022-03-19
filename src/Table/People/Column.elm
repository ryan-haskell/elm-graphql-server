module Table.People.Column exposing
    ( Column
    , id, name, email
    , toString
    )

{-|

@docs Column
@docs id, name, email

@docs toString

-}


type Column
    = Id
    | Name
    | Email


id : Column
id =
    Id


name : Column
name =
    Name


email : Column
email =
    Email


toString : Column -> String
toString column =
    case column of
        Id ->
            "id"

        Name ->
            "name"

        Email ->
            "email"
