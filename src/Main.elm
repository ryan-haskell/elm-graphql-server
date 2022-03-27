module Main exposing (main)

import Dict exposing (Dict)
import GraphQL.Context
import GraphQL.Info
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


main : Program Json.Decode.Value Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { onResponse : Maybe (Json.Decode.Value -> Cmd Msg)
    }


init : Json.Decode.Value -> ( Model, Cmd Msg )
init flags =
    ( { onResponse = Nothing }
    , Cmd.none
    )


runResolver : Json.Decode.Value -> Cmd Msg
runResolver request =
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
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.Hello.argumentDecoder
                , resolver = Resolvers.Query.Hello.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Query", "user" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.User.argumentsDecoder
                , resolver = Resolvers.Query.User.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "Query", "users" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Query.Users.resolver info
                , toJson = Json.Encode.list Schema.User.encode
                }

        Ok ( "Query", "post" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Query.Post.argumentsDecoder
                , resolver = Resolvers.Query.Post.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Query", "posts" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Query.Posts.resolver info
                , toJson = Json.Encode.list Schema.Post.encode
                }

        Ok ( "Mutation", "createPost" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.CreatePost.argumentsDecoder
                , resolver = Resolvers.Mutation.CreatePost.resolver info context
                , toJson = Schema.Post.encode
                }

        Ok ( "Mutation", "updatePost" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.UpdatePost.argumentsDecoder
                , resolver = Resolvers.Mutation.UpdatePost.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Mutation", "deletePost" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.DeletePost.argumentsDecoder
                , resolver = Resolvers.Mutation.DeletePost.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.Post.encode
                }

        Ok ( "Mutation", "createUser" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.CreateUser.argumentsDecoder
                , resolver = Resolvers.Mutation.CreateUser.resolver info
                , toJson = Schema.User.encode
                }

        Ok ( "Mutation", "updateUser" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.UpdateUser.argumentsDecoder
                , resolver = Resolvers.Mutation.UpdateUser.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "Mutation", "deleteUser" ) ->
            createResolver
                { request = request
                , parentDecoder = Json.Decode.succeed ()
                , argsDecoder = Resolvers.Mutation.DeleteUser.argumentsDecoder
                , resolver = Resolvers.Mutation.DeleteUser.resolver info
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( "User", "id" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Id.resolver
                , toJson = Json.Encode.int
                }

        Ok ( "User", "username" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Username.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "User", "avatarUrl" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.AvatarUrl.resolver
                , toJson = Json.Encode.Extra.maybe Json.Encode.string
                }

        Ok ( "User", "posts" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.User.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.User.Posts.resolver
                , toJson = Json.Encode.list Schema.Post.encode
                }

        Ok ( "Post", "id" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Id.resolver
                , toJson = Json.Encode.int
                }

        Ok ( "Post", "imageUrls" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.ImageUrls.resolver
                , toJson = Json.Encode.list Json.Encode.string
                }

        Ok ( "Post", "caption" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Caption.resolver
                , toJson = Json.Encode.string
                }

        Ok ( "Post", "createdAt" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.CreatedAt.resolver
                , toJson = Json.Encode.int << Time.posixToMillis
                }

        Ok ( "Post", "author" ) ->
            createResolver
                { request = request
                , parentDecoder = Schema.Post.decoder
                , argsDecoder = Json.Decode.succeed ()
                , resolver = Resolvers.Post.Author.resolver
                , toJson = Json.Encode.Extra.maybe Schema.User.encode
                }

        Ok ( objectName, fieldName ) ->
            Ports.failure
                { request = request
                , reason =
                    "Elm application is missing a resolver for {{objectName}}.{{fieldName}}"
                        |> String.replace "{{objectName}}" objectName
                        |> String.replace "{{fieldName}}" fieldName
                }

        Err _ ->
            Ports.failure
                { request = request
                , reason = "Elm expected `objectName` and `fieldName` in the request."
                }


createResolver :
    { request : Json.Decode.Value
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
                                { request = options.request
                                , value = options.toJson value
                                }
                    , onFailure =
                        \reason ->
                            Ports.failure
                                { request = options.request
                                , reason = reason
                                }
                    , onDatabaseQuery = ResolverSentDatabaseQuery options.request
                    }

        Err _ ->
            Ports.failure
                { request = options.request
                , reason = "Failed to decode parent/args."
                }



-- UPDATE


type Msg
    = ResolverSentDatabaseQuery
        Json.Decode.Value
        { sql : String
        , onResponse : Json.Decode.Value -> Cmd Msg
        }
    | JavascriptSentDatabaseResponse
        { request : Json.Decode.Value
        , response : Json.Decode.Value
        }
    | JavascriptRequestedResolver
        { request : Json.Decode.Value
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResolverSentDatabaseQuery request options ->
            ( { model | onResponse = Just options.onResponse }
            , Ports.databaseOut
                { request = request
                , sql = options.sql
                }
            )

        JavascriptRequestedResolver { request } ->
            ( model
            , runResolver request
            )

        JavascriptSentDatabaseResponse { request, response } ->
            case model.onResponse of
                Just onResponse ->
                    ( { model | onResponse = Nothing }
                    , onResponse response
                    )

                Nothing ->
                    ( model
                    , Ports.failure
                        { request = request
                        , reason = "Unexpected response from the database."
                        }
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.databaseIn JavascriptSentDatabaseResponse
        , Ports.runResolver JavascriptRequestedResolver
        ]
