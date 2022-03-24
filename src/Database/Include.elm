module Database.Include exposing (fromListToItem, fromListToMaybe)

import GraphQL.Response exposing (Response)


fromListToMaybe : (List item -> Response (List item)) -> Maybe item -> Response (Maybe item)
fromListToMaybe fn maybeItem =
    case maybeItem of
        Just item ->
            fn [ item ]
                |> GraphQL.Response.map List.head

        Nothing ->
            GraphQL.Response.ok Nothing


fromListToItem : (List item -> Response (List item)) -> item -> Response item
fromListToItem fn item =
    fn [ item ]
        |> GraphQL.Response.map (List.head >> Maybe.withDefault item)
