module Schema.UserAuthoredPost exposing (UserAuthoredPost, decoder, encode, selectAll)

import Json.Decode
import Json.Encode
import Table.UserAuthoredPost.Select


type alias UserAuthoredPost =
    { id : Int
    , postId : Int
    , userId : Int
    }


selectAll : Table.UserAuthoredPost.Select.Decoder UserAuthoredPost
selectAll =
    Table.UserAuthoredPost.Select.new UserAuthoredPost
        |> Table.UserAuthoredPost.Select.id
        |> Table.UserAuthoredPost.Select.postId
        |> Table.UserAuthoredPost.Select.userId


decoder : Json.Decode.Decoder UserAuthoredPost
decoder =
    Json.Decode.map3 UserAuthoredPost
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "postId" Json.Decode.int)
        (Json.Decode.field "userId" Json.Decode.int)


encode : UserAuthoredPost -> Json.Decode.Value
encode edge =
    Json.Encode.object
        (List.filterMap identity
            [ Just ( "id", Json.Encode.int edge.id )
            , Just ( "postId", Json.Encode.int edge.postId )
            , Just ( "userId", Json.Encode.int edge.userId )
            ]
        )
