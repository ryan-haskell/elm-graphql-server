module GraphQL exposing (Response)

import Json.Decode as Json


type alias Response value =
    Result Json.Value value
