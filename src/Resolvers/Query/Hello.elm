module Resolvers.Query.Hello exposing (Arguments, argumentDecoder, resolver)

import GraphQL.Response exposing (Response)
import Json.Decode


type alias Arguments =
    { name : Maybe String
    }


argumentDecoder : Json.Decode.Decoder Arguments
argumentDecoder =
    Json.Decode.map Arguments
        (Json.Decode.maybe (Json.Decode.field "name" Json.Decode.string))


resolver : () -> Arguments -> Response String
resolver parent args =
    case args.name of
        Just name ->
            GraphQL.Response.ok ("Hey, " ++ name ++ "!")

        Nothing ->
            GraphQL.Response.ok "Hello!"
