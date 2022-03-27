port module Ports exposing (databaseIn, databaseOut, failure, runResolver, success)

import Json.Decode
import Json.Encode


success :
    { request : Json.Decode.Value
    , value : Json.Decode.Value
    }
    -> Cmd msg
success options =
    outgoing
        { tag = "SUCCESS"
        , request = options.request
        , payload = options.value
        }


failure :
    { request : Json.Decode.Value
    , reason : String
    }
    -> Cmd msg
failure options =
    outgoing
        { tag = "FAILURE"
        , request = options.request
        , payload = Json.Encode.string options.reason
        }


databaseOut :
    { request : Json.Decode.Value
    , sql : String
    }
    -> Cmd msg
databaseOut options =
    outgoing
        { tag = "DATABASE_OUT"
        , request = options.request
        , payload = Json.Encode.string options.sql
        }


port databaseIn :
    ({ request : Json.Decode.Value
     , response : Json.Decode.Value
     }
     -> msg
    )
    -> Sub msg


port runResolver :
    ({ request : Json.Decode.Value
     }
     -> msg
    )
    -> Sub msg


port outgoing :
    { request : Json.Decode.Value
    , tag : String
    , payload : Json.Decode.Value
    }
    -> Cmd msg
