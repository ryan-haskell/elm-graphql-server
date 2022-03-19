port module Worker exposing (main)

import Dict exposing (Dict)
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Json.Encode.Extra
import Platform
import Random
import Resolvers.Person.Email
import Resolvers.Person.Id
import Resolvers.Person.Name
import Resolvers.Query.Goodbye
import Resolvers.Query.Hello
import Resolvers.Query.People
import Resolvers.Query.Person


port success : Json.Decode.Value -> Cmd msg


port failure : Json.Decode.Value -> Cmd msg


port databaseOut : { id : RequestId, sql : String } -> Cmd msg


port databaseIn : ({ id : RequestId, response : Json.Decode.Value } -> msg) -> Sub msg


main : Program Json.Decode.Value Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { requests : Dict RequestId (Json.Decode.Value -> Cmd Msg)
    }


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flags =
    ( { requests = Dict.empty
      }
    , case
        Json.Decode.decodeValue
            (Json.Decode.map2 Tuple.pair
                (Json.Decode.field "objectName" Json.Decode.string)
                (Json.Decode.field "fieldName" Json.Decode.string)
            )
            flags
      of
        Ok ( "Query", "hello" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.Hello.argumentDecoder
                , resolver = Resolvers.Query.Hello.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Query", "goodbye" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Query.Goodbye.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Query", "person" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.Person.argumentsDecoder
                , resolver = Resolvers.Query.Person.resolver
                , toJson = Json.Encode.Extra.maybe Resolvers.Query.Person.encode
                }

        Ok ( "Query", "people" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Query.People.resolver
                , toJson = Json.Encode.list Resolvers.Query.Person.encode
                }

        Ok ( "Person", "id" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Resolvers.Query.Person.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Person.Id.resolver
                , toJson = Json.Encode.int
                }

        Ok ( "Person", "name" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Resolvers.Query.Person.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Person.Name.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Person", "email" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Resolvers.Query.Person.decoder
                , argsDecoder = Json.Decode.succeed ()
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
    { flags : Json.Decode.Value
    , parentDecoder : Json.Decode.Decoder parent
    , argsDecoder : Json.Decode.Decoder args
    , resolver : parent -> args -> Response value
    , toJson : value -> Json.Decode.Value
    }
    -> Cmd Msg
createResolver options =
    let
        inputDecoder : Json.Decode.Decoder { parent : parent, args : args }
        inputDecoder =
            Json.Decode.map2 (\p a -> { parent = p, args = a })
                (Json.Decode.field "parent" options.parentDecoder)
                (Json.Decode.field "args" options.argsDecoder)
    in
    case Json.Decode.decodeValue inputDecoder options.flags of
        Ok { parent, args } ->
            options.resolver parent args
                |> GraphQL.Response.toCmd
                    { onSuccess = options.toJson >> success
                    , onFailure = failure
                    , onDatabaseQuery = ResolverSentDatabaseQuery
                    }

        Err _ ->
            Json.Encode.string "Failed to decode parent/args."
                |> failure



-- UPDATE


type Msg
    = ResolverSentDatabaseQuery { sql : String, onResponse : Json.Decode.Value -> Cmd Msg }
    | WorkerGeneratedRequestId { sql : String, onResponse : Json.Decode.Value -> Cmd Msg } RequestId
    | JavascriptSentDatabaseResponse { id : RequestId, response : Json.Decode.Value }


type alias RequestId =
    Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResolverSentDatabaseQuery options ->
            ( model
            , Random.int 0 Random.maxInt
                |> Random.generate (WorkerGeneratedRequestId options)
            )

        WorkerGeneratedRequestId options requestId ->
            ( { model | requests = Dict.insert requestId options.onResponse model.requests }
            , databaseOut
                { id = requestId
                , sql = options.sql
                }
            )

        JavascriptSentDatabaseResponse { id, response } ->
            case Dict.get id model.requests of
                Just onResponse ->
                    ( { model | requests = Dict.remove id model.requests }
                    , onResponse response
                    )

                Nothing ->
                    ( model
                    , failure (Json.Encode.string ("Couldn't find a request with ID: " ++ String.fromInt id))
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    databaseIn JavascriptSentDatabaseResponse
