module Main exposing (main)

import AssocList
import Dict exposing (Dict)
import GraphQL.Context
import GraphQL.Info exposing (Info)
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Json.Encode.Extra
import Platform
import Ports
import Resolvers.Mutation.CreatePost
import Resolvers.Mutation.CreateUser
import Resolvers.Mutation.DeletePost
import Resolvers.Mutation.DeleteUser
import Resolvers.Mutation.UpdatePost
import Resolvers.Mutation.UpdateUser
import Resolvers.Post.Author
import Resolvers.Post.Caption
import Resolvers.Post.CreatedAt
import Resolvers.Post.Id
import Resolvers.Post.ImageUrls
import Resolvers.Query.Hello
import Resolvers.Query.Post
import Resolvers.Query.Posts
import Resolvers.Query.User
import Resolvers.Query.Users
import Resolvers.User.AvatarUrl
import Resolvers.User.Id
import Resolvers.User.Posts
import Resolvers.User.Username
import Schema.Post
import Schema.User
import Time


main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


type alias ResolverId =
    String


type alias BatchResolverId =
    String


type alias Model =
    { batchResponseDict : Dict BatchResolverId (List (List Int -> Cmd Msg))
    , databaseResponseDict : AssocList.Dict ResolverId (Json.Decode.Value -> Cmd Msg)
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { batchResponseDict = Dict.empty
      , databaseResponseDict = AssocList.empty
      }
    , Cmd.none
    )


runResolver : ResolverId -> Json.Decode.Value -> Cmd Msg
runResolver resolverId request =
    let
        objectAndFieldResult : Result Json.Decode.Error ( String, String )
        objectAndFieldResult =
            Json.Decode.decodeValue
                (Json.Decode.map2 Tuple.pair
                    (Json.Decode.field "objectName" Json.Decode.string)
                    (Json.Decode.field "fieldName" Json.Decode.string)
                )
                request

        context : GraphQL.Context.Context
        context =
            GraphQL.Context.fromJson "context" request

        info : GraphQL.Info.Info
        info =
            GraphQL.Info.fromJson "info" request
    in
    case objectAndFieldResult of
        Ok ( "Query", "hello" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.Hello.argumentDecoder
                , resolver = Resolvers.Query.Hello.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Query", "user" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.User.argumentsDecoder
                , resolver = Resolvers.Query.User.resolver
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "Query", "users" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Query.Users.resolver
                , toJson = Json.Encode.list Schema.User.encode
                }

        Ok ( "Query", "post" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.Post.argumentsDecoder
                , resolver = Resolvers.Query.Post.resolver
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Query", "posts" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Query.Posts.resolver
                , toJson = Json.Encode.list Schema.Post.encode
                }

        Ok ( "Mutation", "createPost" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.CreatePost.argumentsDecoder
                , resolver = Resolvers.Mutation.CreatePost.resolver context
                , toJson = Schema.Post.encode
                }

        Ok ( "Mutation", "updatePost" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.UpdatePost.argumentsDecoder
                , resolver = Resolvers.Mutation.UpdatePost.resolver
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Mutation", "deletePost" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.DeletePost.argumentsDecoder
                , resolver = Resolvers.Mutation.DeletePost.resolver
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Mutation", "createUser" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.CreateUser.argumentsDecoder
                , resolver = Resolvers.Mutation.CreateUser.resolver
                , toJson = Schema.User.encode
                }

        Ok ( "Mutation", "updateUser" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.UpdateUser.argumentsDecoder
                , resolver = Resolvers.Mutation.UpdateUser.resolver
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "Mutation", "deleteUser" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.DeleteUser.argumentsDecoder
                , resolver = Resolvers.Mutation.DeleteUser.resolver
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "User", "id" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Id.resolver
                , toJson = Json.Encode.int
                }

        Ok ( "User", "username" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Username.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "User", "avatarUrl" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.AvatarUrl.resolver
                , toJson = Json.Encode.Extra.maybe Json.Encode.string
                }

        Ok ( "User", "posts" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Posts.resolver info
                , toJson = Json.Encode.list Schema.Post.encode
                }

        Ok ( "Post", "id" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Id.resolver
                , toJson = Json.Encode.int
                }

        Ok ( "Post", "imageUrls" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.ImageUrls.resolver
                , toJson = Json.Encode.list Json.Encode.string
                }

        Ok ( "Post", "caption" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Caption.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Post", "createdAt" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.CreatedAt.resolver
                , toJson = Json.Encode.int << Time.posixToMillis
                }

        Ok ( "Post", "author" ) ->
            createResolver
                { resolverId = resolverId
                , request = request
                , info = info
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Author.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( objectName, fieldName ) ->
            Ports.failure
                { resolverId = resolverId
                , reason =
                    "Elm application is missing a resolver for {{objectName}}.{{fieldName}}"
                        |> String.replace "{{objectName}}" objectName
                        |> String.replace "{{fieldName}}" fieldName
                }

        Err _ ->
            Ports.failure
                { resolverId = resolverId
                , reason = "Elm expected `objectName` and `fieldName` in the request."
                }


createResolver :
    { resolverId : ResolverId
    , info : Info
    , request : Json.Decode.Value
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
    case Json.Decode.decodeValue inputDecoder options.request of
        Ok { parent, args } ->
            options.resolver parent args
                |> GraphQL.Response.toCmd
                    { onSuccess =
                        \value ->
                            Ports.success
                                { resolverId = options.resolverId
                                , value = options.toJson value
                                }
                    , onFailure =
                        \reason ->
                            Ports.failure
                                { resolverId = options.resolverId
                                , reason = reason
                                }
                    , onDatabaseQuery =
                        ElmSentDatabaseQuery
                            options.resolverId
                            (GraphQL.Info.toBatchId options.info)
                    , onBatchQuery =
                        ElmSentBatchRequest
                            options.resolverId
                    }

        Err _ ->
            Ports.failure
                { resolverId = options.resolverId
                , reason = "Failed to decode parent/args."
                }



-- UPDATE


type Msg
    = ElmSentDatabaseQuery
        ResolverId
        BatchResolverId
        { sql : String
        , onResponse : Json.Decode.Value -> Cmd Msg
        }
    | ElmSentBatchRequest
        ResolverId
        { id : Int
        , info : Info
        , onResponse : List Int -> Cmd Msg
        }
    | JavascriptSentDatabaseResponse
        { resolverId : ResolverId
        , response : Json.Decode.Value
        }
    | JavascriptSentBatchResponse
        { resolverId : ResolverId
        , batchId : BatchResolverId
        , ids : List Int
        }
    | JavascriptRequestedResolver
        { resolverId : ResolverId
        , request : Json.Decode.Value
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- case Debug.log "msg" msg of
        ElmSentDatabaseQuery resolverId batchId options ->
            ( { model | databaseResponseDict = AssocList.insert resolverId options.onResponse model.databaseResponseDict }
            , Ports.databaseOut
                { resolverId = resolverId
                , batchId = batchId
                , sql = options.sql
                }
            )

        ElmSentBatchRequest resolverId options ->
            let
                addCmdToList : Maybe (List (List Int -> Cmd Msg)) -> Maybe (List (List Int -> Cmd Msg))
                addCmdToList maybeList =
                    maybeList
                        |> Maybe.withDefault []
                        |> (\list -> options.onResponse :: list)
                        |> Just
            in
            ( { model | batchResponseDict = Dict.update (GraphQL.Info.toBatchId options.info) addCmdToList model.batchResponseDict }
            , Ports.batchRequestOut
                { resolverId = resolverId
                , id = options.id
                , batchId = GraphQL.Info.toBatchId options.info
                }
            )

        JavascriptRequestedResolver { resolverId, request } ->
            ( model
            , runResolver resolverId request
            )

        JavascriptSentDatabaseResponse { resolverId, response } ->
            case AssocList.get resolverId model.databaseResponseDict of
                Just onResponse ->
                    ( { model | databaseResponseDict = AssocList.remove resolverId model.databaseResponseDict }
                    , onResponse response
                    )

                Nothing ->
                    ( model
                    , Ports.failure
                        { resolverId = resolverId
                        , reason = "Unexpected database response from JavaScript."
                        }
                    )

        JavascriptSentBatchResponse { resolverId, batchId, ids } ->
            case Dict.get batchId model.batchResponseDict of
                Just listOfHandlers ->
                    ( { model | batchResponseDict = Dict.remove batchId model.batchResponseDict }
                    , Cmd.batch (List.map (\onResponse -> onResponse ids) listOfHandlers)
                    )

                Nothing ->
                    ( model
                    , Ports.failure
                        { resolverId = resolverId
                        , reason = "Unexpected batch response from JavaScript."
                        }
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.databaseIn JavascriptSentDatabaseResponse
        , Ports.batchIn JavascriptSentBatchResponse
        , Ports.runResolver JavascriptRequestedResolver
        ]
