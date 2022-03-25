module GraphQL.Info exposing (Info, fromJson, hasSelection)

import Json.Decode


type Info
    = Info Internals


type alias Internals =
    { selections : List String
    }


fromJson : String -> Json.Decode.Value -> Info
fromJson fieldName json =
    case Json.Decode.decodeValue (Json.Decode.field fieldName decoder) json of
        Ok context ->
            context

        Err reason ->
            fallback


fallback : Info
fallback =
    Info { selections = [] }


decoder : Json.Decode.Decoder Info
decoder =
    Json.Decode.map Info internalDecoder


internalDecoder : Json.Decode.Decoder Internals
internalDecoder =
    let
        selectionSetDecoder : Json.Decode.Decoder (List String)
        selectionSetDecoder =
            Json.Decode.at [ "selectionSet", "selections" ]
                (Json.Decode.list
                    (Json.Decode.at [ "name", "value" ] Json.Decode.string)
                )
    in
    Json.Decode.map Internals
        (Json.Decode.field "fieldNodes"
            (Json.Decode.map List.concat
                (Json.Decode.oneOf
                    [ Json.Decode.list selectionSetDecoder
                    , Json.Decode.succeed []
                    ]
                )
            )
        )


{-| Check if this request includes a selected field

**Example:**

    query {
        posts {
            id
            author
        }
    }


    GraphQL.Info.hasSelection "id" info == True
    GraphQL.Info.hasSelection "author" info == True

    GraphQL.Info.hasSelection "createdAt" info == False
    GraphQL.Info.hasSelection "caption" info == False

-}
hasSelection : String -> Info -> Bool
hasSelection field (Info info) =
    List.member field info.selections
