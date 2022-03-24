module Database.Select exposing
    ( Decoder, new
    , with, none
    , mapDecoder
    , toSql, toJsonDecoder
    )

{-|

@docs Decoder, new
@docs with, none

@docs mapDecoder

@docs toSql, toJsonDecoder

-}

import Json.Decode


type Decoder column value
    = Decoder
        { toColumnName : column -> String
        , decoder : Json.Decode.Decoder value
        , columns : List column
        }


new :
    (column -> String)
    -> value
    -> Decoder column value
new toColumnName fn =
    Decoder
        { toColumnName = toColumnName
        , decoder = Json.Decode.succeed fn
        , columns = []
        }


with :
    column
    -> Json.Decode.Decoder value
    -> Decoder column (value -> output)
    -> Decoder column output
with column decoder (Decoder select) =
    Decoder
        { toColumnName = select.toColumnName
        , columns = column :: select.columns
        , decoder =
            Json.Decode.map2 (<|)
                select.decoder
                (Json.Decode.field
                    (select.toColumnName column)
                    decoder
                )
        }


none : Decoder column (Maybe value -> output) -> Decoder column output
none (Decoder select) =
    Decoder
        { toColumnName = select.toColumnName
        , columns = select.columns
        , decoder =
            Json.Decode.map2 (<|)
                select.decoder
                (Json.Decode.succeed Nothing)
        }


toSql : Decoder column value -> String
toSql decoder =
    toColumnList decoder |> String.join ", "


toJsonDecoder : Decoder column value -> Json.Decode.Decoder value
toJsonDecoder (Decoder select) =
    select.decoder


mapDecoder : (Json.Decode.Decoder a -> Json.Decode.Decoder b) -> Decoder column a -> Decoder column b
mapDecoder fn (Decoder select) =
    Decoder
        { toColumnName = select.toColumnName
        , columns = select.columns
        , decoder = fn select.decoder
        }



-- INTERNALS


toColumnList : Decoder column value -> List String
toColumnList (Decoder select) =
    select.columns
        |> List.map select.toColumnName
        |> List.reverse
