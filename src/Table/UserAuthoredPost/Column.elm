module Table.UserAuthoredPost.Column exposing
    ( Column
    , id, postId, userId
    , toColumnName
    )

{-|

@docs Column
@docs id, postId, userId

@docs toColumnName

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


toColumnName : Column -> String
toColumnName column =
    case column of
        Id ->
            "id"

        PostId ->
            "postId"

        UserId ->
            "userId"
