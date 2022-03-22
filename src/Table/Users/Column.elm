module Table.Users.Column exposing
    ( Column
    , id, username, avatarUrl
    , toString
    )

{-|

@docs Column
@docs id, username, avatarUrl

@docs toString

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


toString : Column -> String
toString column =
    case column of
        Id ->
            "id"

        Username ->
            "username"

        AvatarUrl ->
            "avatarUrl"
