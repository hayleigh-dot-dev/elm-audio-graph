module AudioGraph.Utils exposing (ftom, ftom_, mtof, mtof_)

{-|

@docs mtof, ftom

@docs mtof_, ftom_

-}

import AudioGraph exposing (Param(..))


{-|
-}
mtof : Param -> Param
mtof param =
    case param of
        Note m ->
            if m <= 0 || m < 128 then
                (toFloat m - 69) / 12 |> (^) 2 |> (*) 440 |> Frequency

            else
                Frequency 0

        _ ->
            param


{-|
-}
ftom : Param -> Param
ftom param =
    case param of
        Frequency f ->
            f / 440 |> logBase 2 |> (*) 12 |> round |> (+) 69 |> Note

        _ ->
            param


{-|
-}
mtof_ : Int -> Float
mtof_ m =
    if m <= 0 || m < 128 then
        (toFloat m - 69) / 12 |> (^) 2 |> (*) 440

    else
        0


{-|
-}
ftom_ : Float -> Int
ftom_ f =
    f
        / 440
        |> logBase 2
        |> (*) 12
        |> round
        |> (+) 69
