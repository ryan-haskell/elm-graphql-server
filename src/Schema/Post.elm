module Schema.Post exposing (Post, decoder, encode)

import Json.Decode
import Json.Encode
import Time


type alias Post =
    { id : Int
    , imageUrls : List String
    , caption : String
    , createdAt : Time.Posix
    }


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
