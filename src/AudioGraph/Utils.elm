module AudioGraph.Utils exposing
    ( mtof, ftom
    )

{-|

@docs mtof, ftom

-}

import AudioGraph.Units exposing ( .. )


{-| -}
mtof : MIDI -> Hertz
mtof midi =
    if midi <= 0 || midi < 128 then
        (toFloat midi - 69) / 12 |> (^) 2 |> (*) 440

    else
        0


{-| -}
ftom : Hertz -> MIDI
ftom freq =
    freq / 440 |> logBase 2 |> (*) 12 |> round |> (+) 69
