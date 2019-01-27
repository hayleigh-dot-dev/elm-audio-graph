module AudioGraph.Units exposing (ChannelNumber, Hertz, KValue, MIDI)

{-|

@docs ChannelNumber, Hertz, KValue, MIDI

-}


{-| Represents the channel number of an auidio node input or output. -}
type alias ChannelNumber =
    Int


{-| Represents frequency in Herts. -}
type alias Hertz =
    Float


{-| Represents an arbitrary control value. The "K" is a naming convention that
has its roots in MUSIC 11 and has been adopted by most music computing platforms
including Csound and SuperCollider.
-}
type alias KValue =
    Float


{-| Represents a MIDI note number. -}
type alias MIDI =
    Int
