module Table.Posts.Column exposing
    ( Column
    , id, imageUrls, caption, createdAt
    , toColumnName
    )

{-|

@docs Column
@docs id, imageUrls, caption, createdAt

@docs toColumnName

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


toColumnName : Column -> String
toColumnName column =
    case column of
        Id ->
            "id"

        ImageUrls ->
            "imageUrls"

        Caption ->
            "caption"

        CreatedAt ->
            "createdAt"
