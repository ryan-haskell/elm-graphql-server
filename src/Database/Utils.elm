module Database.Utils exposing (wrapStringValue)

{-| Wraps raw string values so string literals don't accidentally
become invalid SQL syntax or [bobby drop tables](https://xkcd.com/327/).

SQL strings are wrapped in **single quotes**, and we use `''` to escape single quote characters

Here are some examples:

  - `Ryan` -> `'Ryan'`
  - `Ryan's so cool!` -> `'Ryan''s so cool!'`
  - `Ryan "Cool guy" Haskell` -> `'Ryan "Cool guy" Haskell'`

-}


wrapStringValue : String -> String
wrapStringValue str =
    "'" ++ String.replace "'" "''" str ++ "'"
