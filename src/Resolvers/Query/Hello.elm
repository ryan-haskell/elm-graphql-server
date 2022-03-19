module Resolvers.Query.Hello exposing (Arguments, argumentDecoder, resolver)

import GraphQL
import Json.Decode as Json


type alias Arguments =
    { name : Maybe String
    }


argumentDecoder : Json.Decoder Arguments
argumentDecoder =
    Json.map Arguments
        (Json.maybe (Json.field "name" Json.string))


resolver : () -> Arguments -> GraphQL.Response String
resolver parent args =
    case args.name of
        Just name ->
            Ok ("Hey, " ++ name ++ "!")

        Nothing ->
            Ok "Hello!"
