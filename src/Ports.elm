port module Ports exposing
    ( batchIn
    , batchRequestOut
    , databaseIn
    , databaseOut
    , failure
    , runResolver
    , success
    )

import Json.Decode
import Json.Encode


success :
    { resolverId : String
    , value : Json.Decode.Value
    }
    -> Cmd msg
success options =
    outgoing
        { tag = "SUCCESS"
        , resolverId = options.resolverId
        , payload = options.value
        }


failure :
    { resolverId : String
    , reason : String
    }
    -> Cmd msg
failure options =
    outgoing
        { tag = "FAILURE"
        , resolverId = options.resolverId
        , payload = Json.Encode.string options.reason
        }


batchRequestOut :
    { resolverId : String
    , id : Int
    , pathId : String
    }
    -> Cmd msg
batchRequestOut options =
    outgoing
        { tag = "BATCH_OUT"
        , resolverId = options.resolverId
        , payload =
            Json.Encode.object
                [ ( "id", Json.Encode.int options.id )
                , ( "pathId", Json.Encode.string options.pathId )
                ]
        }


databaseOut :
    { resolverId : String
    , sql : String
    }
    -> Cmd msg
databaseOut options =
    outgoing
        { tag = "DATABASE_OUT"
        , resolverId = options.resolverId
        , payload = Json.Encode.string options.sql
        }


port databaseIn :
    ({ resolverId : String
     , response : Json.Decode.Value
     }
     -> msg
    )
    -> Sub msg


port batchIn :
    ({ resolverId : String
     , pathId : String
     , ids : List Int
     }
     -> msg
    )
    -> Sub msg


port runResolver :
    ({ resolverId : String
     , request : Json.Decode.Value
     }
     -> msg
    )
    -> Sub msg


port outgoing :
    { resolverId : String
    , tag : String
    , payload : Json.Decode.Value
    }
    -> Cmd msg
