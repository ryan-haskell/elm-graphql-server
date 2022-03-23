module Table.UserAuthoredPost.Value exposing (Value, postId, userId)

import Database.Value
import Table.UserAuthoredPost.Column


type alias Value =
    Database.Value.Value Table.UserAuthoredPost.Column.Column


postId : Int -> Value
postId value =
    Database.Value.int Table.UserAuthoredPost.Column.postId value


userId : Int -> Value
userId value =
    Database.Value.int Table.UserAuthoredPost.Column.userId value
