port module Main exposing (main)

import Dict exposing (Dict)
import GraphQL.Context
import GraphQL.Info
import GraphQL.Response exposing (Response)
import Json.Decode
import Json.Encode
import Json.Encode.Extra
import Platform
import Random
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
    let
        objectAndFieldResult : Result Json.Decode.Error ( String, String )
        objectAndFieldResult =
            Json.Decode.decodeValue
                (Json.Decode.map2 Tuple.pair
                    (Json.Decode.field "objectName" Json.Decode.string)
                    (Json.Decode.field "fieldName" Json.Decode.string)
                )
                flags

        context : GraphQL.Context.Context
        context =
            GraphQL.Context.fromJson "context" flags

        info : GraphQL.Info.Info
        info =
            GraphQL.Info.fromJson "info" flags
    in
    ( { requests = Dict.empty }
    , case objectAndFieldResult of
        Ok ( "Query", "hello" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.Hello.argumentDecoder
                , resolver = Resolvers.Query.Hello.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Query", "user" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.User.argumentsDecoder
                , resolver = Resolvers.Query.User.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "Query", "users" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Query.Users.resolver info
                , toJson = Json.Encode.list Schema.User.encode
                }

        Ok ( "Query", "post" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.Post.argumentsDecoder
                , resolver = Resolvers.Query.Post.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Query", "posts" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Query.Posts.resolver info
                , toJson = Json.Encode.list Schema.Post.encode
                }

        Ok ( "Mutation", "createPost" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.CreatePost.argumentsDecoder
                , resolver = Resolvers.Mutation.CreatePost.resolver info context
                , toJson = Schema.Post.encode
                }

        Ok ( "Mutation", "updatePost" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.UpdatePost.argumentsDecoder
                , resolver = Resolvers.Mutation.UpdatePost.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Mutation", "deletePost" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.DeletePost.argumentsDecoder
                , resolver = Resolvers.Mutation.DeletePost.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Mutation", "createUser" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.CreateUser.argumentsDecoder
                , resolver = Resolvers.Mutation.CreateUser.resolver
                , toJson = Schema.User.encode
                }

        Ok ( "Mutation", "updateUser" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.UpdateUser.argumentsDecoder
                , resolver = Resolvers.Mutation.UpdateUser.resolver
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "Mutation", "deleteUser" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.DeleteUser.argumentsDecoder
                , resolver = Resolvers.Mutation.DeleteUser.resolver
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "User", "id" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Id.resolver
                , toJson = Json.Encode.int
                }

        Ok ( "User", "username" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Username.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "User", "avatarUrl" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.AvatarUrl.resolver
                , toJson = Json.Encode.Extra.maybe Json.Encode.string
                }

        Ok ( "User", "posts" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Posts.resolver
                , toJson = Json.Encode.list Schema.Post.encode
                }

        Ok ( "Post", "id" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Id.resolver
                , toJson = Json.Encode.int
                }

        Ok ( "Post", "imageUrls" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.ImageUrls.resolver
                , toJson = Json.Encode.list Json.Encode.string
                }

        Ok ( "Post", "caption" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Caption.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Post", "createdAt" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.CreatedAt.resolver
                , toJson = Json.Encode.int << Time.posixToMillis
                }

        Ok ( "Post", "author" ) ->
            createResolver
                { flags = flags
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Author.resolver
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
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
