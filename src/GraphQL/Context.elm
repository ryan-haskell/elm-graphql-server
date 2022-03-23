module GraphQL.Context exposing (Context, decoder, fallback)

import Json.Decode


type alias Context =
    { currentUserId : Maybe Int
    }


fallback : Context
fallback =
    { currentUserId = Nothing
    }


decoder : Json.Decode.Decoder Context
decoder =
    Json.Decode.map Context
        (Json.Decode.field "currentUserId"
            (Json.Decode.string |> Json.Decode.map String.toInt)
        )
