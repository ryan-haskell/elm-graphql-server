module Table.Posts.Column exposing
    ( Column
    , id, imageUrls, caption
    , toString
    )

{-|

@docs Column
@docs id, imageUrls, caption

@docs toString

-}


type Column
    = Id
    | ImageUrls
    | Caption


id : Column
id =
    Id


imageUrls : Column
imageUrls =
    ImageUrls


caption : Column
caption =
    Caption


toString : Column -> String
toString column =
    case column of
        Id ->
            "id"

        ImageUrls ->
            "imageUrls"

        Caption ->
            "caption"
