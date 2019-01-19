module AudioGraph.Utils exposing
    ( mtof, ftom
    )

{-|

@docs mtof, ftom

@docs mtof_, ftom_

-}

import AudioGraph.Units exposing (..)


{-| -}
mtof : MIDI -> Hertz
mtof m =
    if m <= 0 || m < 128 then
        (toFloat m - 69) / 12 |> (^) 2 |> (*) 440

    else
        0


{-| -}
ftom : Hertz -> MIDI
ftom f =
    f / 440 |> logBase 2 |> (*) 12 |> round |> (+) 69
