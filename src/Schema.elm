module Schema exposing
    ( Post(..), post
    , User(..), user
    )

{-|

@docs Post, post
@docs User, user

-}

import Database.Select
import Json.Decode
import Json.Encode
import Json.Encode.Extra
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
    { selectAll : Table.Posts.Select.Decoder Post
    , decoder : Json.Decode.Decoder Post
    , encode : Post -> Json.Encode.Value
    }
post =
    { selectAll = post_selectAll
    , decoder = post_decoder
    , encode = post_encode
    }


post_selectAll : Table.Posts.Select.Decoder Post
post_selectAll =
    Database.Select.map Post
        (Table.Posts.Select.new Post_Internals
            |> Table.Posts.Select.id
            |> Table.Posts.Select.imageUrls
            |> Table.Posts.Select.caption
            |> Table.Posts.Select.createdAt
            |> Table.Posts.Select.author
        )


post_decoder : Json.Decode.Decoder Post
post_decoder =
    Json.Decode.map Post
        (Json.Decode.map5 Post_Internals
            (Json.Decode.field "id" Json.Decode.int)
            (Json.Decode.field "imageUrls" (Json.Decode.list Json.Decode.string))
            (Json.Decode.field "caption" Json.Decode.string)
            (Json.Decode.field "createdAt" (Json.Decode.int |> Json.Decode.map Time.millisToPosix))
            (Json.Decode.maybe (Json.Decode.field "author" (Json.Decode.lazy (\_ -> user_decoder))))
        )


post_encode : Post -> Json.Encode.Value
post_encode (Post post_) =
    Json.Encode.object
        [ ( "id", Json.Encode.int post_.id )
        , ( "imageUrls", Json.Encode.list Json.Encode.string post_.imageUrls )
        , ( "caption", Json.Encode.string post_.caption )
        , ( "createdAt", Json.Encode.int (Time.posixToMillis post_.createdAt) )
        , ( "author", Json.Encode.Extra.maybe user_encode post_.author )
        ]



-- USER


type User
    = User User_Internals


type alias User_Internals =
    { id : Int
    , username : String
    , avatarUrl : Maybe String
    , posts : List Post
    }


user :
    { selectAll : Table.Users.Select.Decoder User
    , decoder : Json.Decode.Decoder User
    , encode : User -> Json.Encode.Value
    }
user =
    { selectAll = user_selectAll
    , decoder = user_decoder
    , encode = user_encode
    }


user_selectAll : Table.Users.Select.Decoder User
user_selectAll =
    Database.Select.map User
        (Table.Users.Select.new User_Internals
            |> Table.Users.Select.id
            |> Table.Users.Select.username
            |> Table.Users.Select.avatarUrl
            |> Table.Users.Select.posts
        )


user_decoder : Json.Decode.Decoder User
user_decoder =
    Json.Decode.map User
        (Json.Decode.map4 User_Internals
            (Json.Decode.field "id" Json.Decode.int)
            (Json.Decode.field "username" Json.Decode.string)
            (Json.Decode.maybe (Json.Decode.field "avatarUrl" Json.Decode.string))
            (Json.Decode.field "posts" (Json.Decode.list (Json.Decode.lazy (\_ -> post_decoder))))
        )


user_encode : User -> Json.Encode.Value
user_encode (User user_) =
    Json.Encode.object
        [ ( "id", Json.Encode.int user_.id )
        , ( "username", Json.Encode.string user_.username )
        , ( "avatarUrl", Json.Encode.Extra.maybe Json.Encode.string user_.avatarUrl )
        , ( "posts", Json.Encode.list post_encode user_.posts )
        ]
