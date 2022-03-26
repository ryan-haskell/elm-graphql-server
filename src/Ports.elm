port module Ports exposing (databaseIn, databaseOut, failure, success)

import Json.Decode


port success : Json.Decode.Value -> Cmd msg


port failure : Json.Decode.Value -> Cmd msg


port databaseOut : { id : Int, sql : String } -> Cmd msg


port databaseIn : ({ id : Int, response : Json.Decode.Value } -> msg) -> Sub msg
