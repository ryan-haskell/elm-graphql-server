module Table.Users.Column exposing
    ( Column
    , id, username, avatarUrl
    , toColumnName
    )

{-|

@docs Column
@docs id, username, avatarUrl

@docs toColumnName

-}


type Column
    = Id
    | Username
    | AvatarUrl


id : Column
id =
    Id


username : Column
username =
    Username


avatarUrl : Column
avatarUrl =
    AvatarUrl


toColumnName : Column -> String
toColumnName column =
    case column of
        Id ->
            "id"

        Username ->
            "username"

        AvatarUrl ->
            "avatarUrl"
