module Table.UserAuthoredPost.Column exposing
    ( Column
    , id, postId, userId
    , toString
    )

{-|

@docs Column
@docs id, postId, userId

@docs toString

-}


type Column
    = Id
    | PostId
    | UserId


id : Column
id =
    Id


postId : Column
postId =
    PostId


userId : Column
userId =
    UserId


toString : Column -> String
toString column =
    case column of
        Id ->
            "id"

        PostId ->
            "postId"

        UserId ->
            "userId"
