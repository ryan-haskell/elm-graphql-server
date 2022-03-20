module Database.Optional exposing (Optional(..), decoder, map, toList)

import Json.Decode


type Optional value
    = Present value
    | Absent


decoder : String -> Json.Decode.Decoder value -> Json.Decode.Decoder (Optional value)
decoder fieldName inner =
    Json.Decode.oneOf
        [ Json.Decode.field fieldName inner |> Json.Decode.map Present
        , Json.Decode.succeed Absent
        ]


toList : List (Optional value) -> List value
toList optionals =
    List.filterMap toMaybe optionals


map : (a -> b) -> Optional a -> Optional b
map fn optional =
    case optional of
        Present a ->
            Present (fn a)

        Absent ->
            Absent


toMaybe : Optional a -> Maybe a
toMaybe optional =
    case optional of
        Present value ->
            Just value

        Absent ->
            Nothing
