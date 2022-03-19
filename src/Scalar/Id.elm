module Scalar.Id exposing
    ( Id
    , fromString, toString
    , decoder, encode
    )

{-|

@docs Id
@docs fromString, toString
@docs decoder, encode

-}

import Json.Decode
import Json.Encode


type Id
    = Id String


fromString : String -> Id
fromString =
    Id


toString : Id -> String
toString (Id idStr) =
    idStr


decoder : Json.Decode.Decoder Id
decoder =
    Json.Decode.string
        |> Json.Decode.map fromString


encode : Id -> Json.Decode.Value
encode id =
    Json.Encode.string (toString id)
