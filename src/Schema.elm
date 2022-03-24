module Schema exposing
    ( Post(..), post
    , User(..), user
    )

{-|

@docs Post, post
@docs User, user

-}

import Json.Decode
import Json.Encode
import Table.Posts.Select
import Table.Users.Select
import Time



-- POST


type Post
    = Post Post_Internals


type alias Post_Internals =
    { id : Int
    , imageUrls : List String
    , caption : String
    , createdAt : Time.Posix
    , author : Maybe User
    }


post :
    { decoder : Json.Decode.Decoder Post
    , encode : Post -> Json.Encode.Value
    , selectAll : Table.Posts.Select.Decoder Post
    }
post =
    { selectAll =
        Table.Posts.Select.map Post
            (Table.Posts.Select.new Post_Internals
                |> Table.Posts.Select.id
                |> Table.Posts.Select.imageUrls
                |> Table.Posts.Select.caption
                |> Table.Posts.Select.createdAt
                |> Table.Posts.Select.author
            )
    , decoder =
        Json.Decode.map Post
            (Json.Decode.map5 Post_Internals
                (Json.Decode.field "id" Json.Decode.int)
                (Json.Decode.field "imageUrls" (Json.Decode.list Json.Decode.string))
                (Json.Decode.field "caption" Json.Decode.string)
                (Json.Decode.field "createdAt" (Json.Decode.int |> Json.Decode.map Time.millisToPosix))
                (Json.Decode.maybe (Json.Decode.field "author" user.decoder))
            )
    , encode =
        \(Post post_) ->
            Json.Encode.object
                (List.filterMap identity
                    [ Just ( "id", Json.Encode.int post_.id )
                    , Just ( "imageUrls", Json.Encode.list Json.Encode.string post_.imageUrls )
                    , Just ( "caption", Json.Encode.string post_.caption )
                    , Just ( "createdAt", Json.Encode.int (Time.posixToMillis post_.createdAt) )
                    , post_.author |> Maybe.map (\user_ -> ( "author", user.encode user_ ))
                    ]
                )
    }



-- USER


type User
    = User User_Internals


type alias User_Internals =
    { id : Int
    , username : String
    , avatarUrl : Maybe String
    }


user :
    { decoder : Json.Decode.Decoder User
    , encode : User -> Json.Encode.Value
    , selectAll : Table.Users.Select.Decoder User
    }
user =
    { selectAll =
        Table.Users.Select.map User
            (Table.Users.Select.new User_Internals
                |> Table.Users.Select.id
                |> Table.Users.Select.username
                |> Table.Users.Select.avatarUrl
            )
    , decoder =
        Json.Decode.map User
            (Json.Decode.map3 User_Internals
                (Json.Decode.field "id" Json.Decode.int)
                (Json.Decode.field "username" Json.Decode.string)
                (Json.Decode.maybe (Json.Decode.field "avatarUrl" Json.Decode.string))
            )
    , encode =
        \(User user_) ->
            Json.Encode.object
                (List.filterMap identity
                    [ Just ( "id", Json.Encode.int user_.id )
                    , Just ( "username", Json.Encode.string user_.username )
                    , user_.avatarUrl |> Maybe.map (\avatarUrl -> ( "avatarUrl", Json.Encode.string avatarUrl ))
                    ]
                )
    }
