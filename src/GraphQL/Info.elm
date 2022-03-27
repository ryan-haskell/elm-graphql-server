module GraphQL.Info exposing (Info, fromJson, hasSelection, toBatchId)

import Json.Decode
import Json.Encode


type Info
    = Info Internals


type alias Internals =
    { batchId : String -- Example "posts.author"
    , uniquePathId : String -- Example "posts.[0].author"
    , selections : List String
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
    Info
        { batchId = ""
        , uniquePathId = ""
        , selections = []
        }


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
    Json.Decode.map3 Internals
        (Json.Decode.field "path" pathDecoder |> Json.Decode.map toGeneralPathId)
        (Json.Decode.field "path" pathDecoder |> Json.Decode.map toUniquePathId)
        (Json.Decode.field "fieldNodes"
            (Json.Decode.map List.concat
                (Json.Decode.oneOf
                    [ Json.Decode.list selectionSetDecoder
                    , Json.Decode.succeed []
                    ]
                )
            )
        )


type PathSegment
    = Index Int
    | Field String


pathSegmentDecoder : Json.Decode.Decoder PathSegment
pathSegmentDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map Index Json.Decode.int
        , Json.Decode.map Field Json.Decode.string
        ]


pathDecoder : Json.Decode.Decoder (List PathSegment)
pathDecoder =
    Json.Decode.map2 (\key pathSoFar -> pathSoFar ++ [ key ])
        (Json.Decode.field "key" pathSegmentDecoder)
        (Json.Decode.oneOf
            [ Json.Decode.field "prev"
                (Json.Decode.lazy
                    (\_ -> pathDecoder)
                )
            , Json.Decode.succeed []
            ]
        )


toUniquePathId : List PathSegment -> String
toUniquePathId segments =
    List.map
        (\segment ->
            case segment of
                Index int ->
                    "[0]"

                Field name ->
                    name
        )
        segments
        |> String.join "."


toGeneralPathId : List PathSegment -> String
toGeneralPathId segments =
    List.filterMap
        (\segment ->
            case segment of
                Index int ->
                    Nothing

                Field name ->
                    Just name
        )
        segments
        |> String.join "."


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


toBatchId : Info -> String
toBatchId (Info info) =
    info.batchId
