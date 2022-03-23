module Table.UserAuthoredPost.Select exposing
    ( Decoder, new
    , id, postId, userId
    )

{-|

@docs Decoder, new
@docs id, postId, userId

-}

import Database.Select
import Json.Decode
import Table.UserAuthoredPost.Column


type alias Decoder value =
    Database.Select.Decoder Table.UserAuthoredPost.Column.Column value


new : value -> Decoder value
new value =
    Database.Select.new
        Table.UserAuthoredPost.Column.toString
        value


id : Decoder (Int -> value) -> Decoder value
id decoder =
    Database.Select.with Table.UserAuthoredPost.Column.id
        Json.Decode.int
        decoder


postId : Decoder (Int -> value) -> Decoder value
postId decoder =
    Database.Select.with Table.UserAuthoredPost.Column.postId
        Json.Decode.int
        decoder


userId : Decoder (Int -> value) -> Decoder value
userId decoder =
    Database.Select.with Table.UserAuthoredPost.Column.userId
        Json.Decode.int
        decoder
