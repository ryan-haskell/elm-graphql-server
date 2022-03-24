module GraphQL.Context exposing (Context, fromJson)

import Json.Decode


type alias Context =
    { currentUserId : Maybe Int
    }


fromJson : String -> Json.Decode.Value -> Context
fromJson fieldName json =
    case Json.Decode.decodeValue (Json.Decode.field fieldName decoder) json of
        Ok context ->
            context

        Err _ ->
            fallback


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
