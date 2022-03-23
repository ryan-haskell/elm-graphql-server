module Table.Posts.Column exposing
    ( Column
    , id, imageUrls, caption, createdAt
    , toString
    )

{-|

@docs Column
@docs id, imageUrls, caption, createdAt

@docs toString

-}


type Column
    = Id
    | ImageUrls
    | Caption
    | CreatedAt


id : Column
id =
    Id


imageUrls : Column
imageUrls =
    ImageUrls


caption : Column
caption =
    Caption


createdAt : Column
createdAt =
    CreatedAt


toString : Column -> String
toString column =
    case column of
        Id ->
            "id"

        ImageUrls ->
            "imageUrls"

        Caption ->
            "caption"

        CreatedAt ->
            "createdAt"
