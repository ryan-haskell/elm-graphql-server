module Schema.Post exposing
    ( Post, selectAll
    , decoder, encode
    , id
    )

{-|

@docs Post, selectAll
@docs decoder, encode

@docs id

-}

import Json.Decode
import Json.Encode
import Schema
import Table.Posts.Select


type alias Post =
    Schema.Post


selectAll : Table.Posts.Select.Decoder Schema.Post
selectAll =
    Schema.post.selectAll


decoder : Json.Decode.Decoder Schema.Post
decoder =
    Schema.post.decoder


encode : Schema.Post -> Json.Encode.Value
encode =
    Schema.post.encode


id : Schema.Post -> Int
id (Schema.Post post) =
    post.id
