port module Worker exposing (main)

import Json.Decode as Json
import Json.Encode
import Platform
import Resolvers.Person.Email
import Resolvers.Person.Id
import Resolvers.Person.Name
import Resolvers.Query.Goodbye
import Resolvers.Query.Hello
import Resolvers.Query.Person
import Scalar.Id


port success : Json.Value -> Cmd msg


port failure : Json.Value -> Cmd msg


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
init flags =
    ( Model
    , case
        Json.decodeValue
            (Json.map2 Tuple.pair
                (Json.field "objectName" Json.string)
                (Json.field "fieldName" Json.string)
            )
            flags
      of
        Ok ( "Query", "hello" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.succeed ()
                , argsDecoder = Resolvers.Query.Hello.argumentDecoder
                , resolver = Resolvers.Query.Hello.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Query", "goodbye" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.succeed ()
                , argsDecoder = Json.succeed ()
                , resolver = Resolvers.Query.Goodbye.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Query", "person" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.succeed ()
                , argsDecoder = Json.succeed ()
                , resolver = Resolvers.Query.Person.resolver
                , toJson = Resolvers.Query.Person.encode
                }

        Ok ( "Person", "id" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Resolvers.Query.Person.decoder
                , argsDecoder = Json.succeed ()
                , resolver = Resolvers.Person.Id.resolver
                , toJson = Scalar.Id.encode
                }

        Ok ( "Person", "name" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Resolvers.Query.Person.decoder
                , argsDecoder = Json.succeed ()
                , resolver = Resolvers.Person.Name.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Person", "email" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Resolvers.Query.Person.decoder
                , argsDecoder = Json.succeed ()
                , resolver = Resolvers.Person.Email.resolver
                , toJson = Maybe.map Json.Encode.string >> Maybe.withDefault Json.Encode.null
                }

        Ok ( objectName, fieldName ) ->
            failure
                (Json.Encode.string
                    ("Did not recognize {{objectName}}.{{fieldName}}"
                        |> String.replace "{{objectName}}" objectName
                        |> String.replace "{{fieldName}}" fieldName
                    )
                )

        Err _ ->
            failure (Json.Encode.string "Field was not passed in.")
    )


createResolver :
    { flags : Json.Value
    , parentDecoder : Json.Decoder parent
    , argsDecoder : Json.Decoder args
    , resolver : parent -> args -> Response value
    , toJson : value -> Json.Value
    }
    -> Cmd msg
createResolver options =
    let
        inputDecoder : Json.Decoder { parent : parent, args : args }
        inputDecoder =
            Json.map2 (\p a -> { parent = p, args = a })
                (Json.field "parent" options.parentDecoder)
                (Json.field "args" options.argsDecoder)
    in
    case Json.decodeValue inputDecoder options.flags of
        Ok { parent, args } ->
            options.resolver parent args
                |> Result.map options.toJson
                |> toJavaScript

        Err _ ->
            Err (Json.Encode.string "Failed to decode parent/args.")
                |> toJavaScript


toJavaScript : Result Json.Value Json.Value -> Cmd msg
toJavaScript result =
    case result of
        Ok value ->
            success value

        Err reason ->
            failure reason


type alias Response value =
    Result Json.Value value



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
