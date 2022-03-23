module Schema.Post exposing (Post, decoder, encode, selectAll)

import Json.Decode
import Json.Encode
import Table.Posts.Select
import Time


type alias Post =
    { id : Int
    , imageUrls : List String
    , caption : String
    , createdAt : Time.Posix
    }


selectAll : Table.Posts.Select.Decoder Post
selectAll =
    Table.Posts.Select.new Post
        |> Table.Posts.Select.id
        |> Table.Posts.Select.imageUrls
        |> Table.Posts.Select.caption
        |> Table.Posts.Select.createdAt


decoder : Json.Decode.Decoder Post
decoder =
    Json.Decode.map4 Post
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "imageUrls" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "caption" Json.Decode.string)
        (Json.Decode.field "createdAt" (Json.Decode.int |> Json.Decode.map Time.millisToPosix))


encode : Post -> Json.Decode.Value
encode post =
    Json.Encode.object
        (List.filterMap identity
            [ Just ( "id", Json.Encode.int post.id )
            , Just ( "imageUrls", Json.Encode.list Json.Encode.string post.imageUrls )
            , Just ( "caption", Json.Encode.string post.caption )
            , Just ( "createdAt", Json.Encode.int (Time.posixToMillis post.createdAt) )
            ]
        )