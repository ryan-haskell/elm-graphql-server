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

import Json.Decode as Json
import Json.Encode


type Id
    = Id String


fromString : String -> Id
fromString =
    Id


toString : Id -> String
toString (Id idStr) =
    idStr


decoder : Json.Decoder Id
decoder =
    Json.string |> Json.map fromString


encode : Id -> Json.Value
encode id =
    Json.Encode.string (toString id)
