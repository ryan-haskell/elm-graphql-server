port module Worker exposing (main)

import Json.Decode as Json
import Json.Encode
import Platform


port outgoing : Json.Value -> Cmd msg


main : Program Json.Value Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


type Model
    = Model


init : Json.Value -> ( Model, Cmd Msg )
init json =
    ( Model
    , outgoing (Json.Encode.string "Hello from Elm!")
    )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
