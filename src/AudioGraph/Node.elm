module AudioGraph.Node exposing
    ( Node(..)
    , ID, idFromString, idFromInt, idToString, Type(..), Param(..)
    , getID, getType, getParam, setParam
    , desintationNode, createOscillatorNode, createGainNode, createCustomNode
    )

{-|


# Definition

@docs Node


# Types

@docs ID, idFromString, idFromInt, idToString, Type, Param


# Node Methods

@docs getID, getType, getParam, setParam


# Node Constructors

@docs desintationNode, createOscillatorNode, createGainNode, createCustomNode

-}

import AudioGraph.Units exposing (..)
import Dict exposing (Dict)


{-| `Node` represents a generic audio node.
-}
type Node
    = Node
        { id : ID
        , nodeType : Type
        , params : Dict String Param
        , inputs : Dict ChannelNumber String
        , outputs : Dict ChannelNumber String
        }


{-| -}
type ID
    = ID String


{-| -}
idFromString : String -> ID
idFromString id =
    ID id


{-| -}
idFromInt : Int -> ID
idFromInt id =
    ID (String.fromInt id)


{-| -}
idToString : ID -> String
idToString id =
    case id of
        ID s ->
            s


{-| Based on a Nodes params, we can give it a type. This package has built
in types for the most common Web Audio nodes, but the `Custom` type allows
you to [build your own nodes](#createCustomNode).
-}
type Type
    = Destination
    | Oscillator
    | Gain
    | Custom String


{-| -}
type Param
    = Value KValue -- Represents any arbitrary control value
    | Note MIDI -- MIDI note number
    | Frequency Hertz -- Frequency in Hz
    | Waveform String -- Oscillator waveform. Is be an arbitrary string.
    | Input ChannelNumber
    | Output ChannelNumber



-- NODE METHODS


{-| -}
getID : Node -> ID
getID node =
    case node of
        Node a ->
            a.id


{-| -}
getType : Node -> Type
getType node =
    case node of
        Node a ->
            a.nodeType


{-| -}
getParam : String -> Node -> Maybe Param
getParam param node =
    case node of
        Node a ->
            Dict.get param a.params


{-| -}
setParam : String -> Param -> Node -> Node
setParam param val node =
    case node of
        Node a ->
            case val of
                Value v ->
                    Node { a | params = Dict.update param (Maybe.map (\_ -> Value v)) a.params }

                Note n ->
                    Node { a | params = Dict.update param (Maybe.map (\_ -> Note n)) a.params }

                Frequency f ->
                    Node { a | params = Dict.update param (Maybe.map (\_ -> Frequency f)) a.params }

                Waveform w ->
                    Node { a | params = Dict.update param (Maybe.map (\_ -> Waveform w)) a.params }

                _ ->
                    Node a



-- NODE CONSTRUCTORS


{-| The destination node representss the final destination for all audio in the Web Audio Context.
This is usually your device's speakers. You won't often need to create a destination node directly,
as an [emptyAudioGraph](/AudioGraph#emptyAudioGraph) already includes one.

The destination has an [ID](#ID) of `"_destination"`.

-}
desintationNode : Node
desintationNode =
    Node
        { id = idFromString "_destination"
        , nodeType = Destination
        , params = Dict.empty
        , inputs =
            Dict.fromList
                [ ( 0, "audioIn_Left" )
                , ( 1, "audioIn_Right" )
                ]
        , outputs = Dict.empty
        }


{-| Creates an oscillator node representing a [Web Audio oscillator](https://developer.mozilla.org/en-US/docs/Web/API/OscillatorNode)
-}
createOscillatorNode : ID -> Node
createOscillatorNode id =
    Node
        { id = id
        , nodeType = Oscillator
        , params =
            Dict.fromList
                [ ( "detune", Value 0.0 )
                , ( "frequency", Frequency 440.0 )
                , ( "waveform", Waveform "sine" )
                ]
        , inputs =
            Dict.fromList
                [ ( 0, "frequency" )
                , ( 1, "detune" )
                ]
        , outputs =
            Dict.fromList
                [ ( 0, "audioOut" )
                ]
        }


{-| Creates a gain node representing a [Web Audio gain](https://developer.mozilla.org/en-US/docs/Web/API/GainNode) node.
-}
createGainNode : ID -> Node
createGainNode id =
    Node
        { id = id
        , nodeType = Gain
        , params =
            Dict.fromList
                [ ( "gain", Value 1.0 )
                ]
        , inputs =
            Dict.fromList
                [ ( 0, "audioIn" )
                , ( 1, "gain" )
                ]
        , outputs =
            Dict.fromList
                [ ( 0, "audioOut" )
                ]
        }


{-| You can create your own custom nodes with `createCustomNode` by simply
providing a String to name your new node type, and a dictionary of its default
parameters. Finally, passing a ID as usual will construct the new custom
node.

You can then partially apply `createCustomNode` to create your own node generators:

    createMyAwesomeNode : ID -> Node
    createMyAwesomeNode =
        createCustomNode
            "MyAwesomeNode"
            (Dict.fromList 
                [ ( "awesomeness", Value 100.0 ) 
                ])
            (Dict.fromList 
                [ ( 0, "audioIn" ) 
                ])
            (Dict.fromList 
                [ ( 0, "audioOut" ) 
                ])

-}
createCustomNode :
    String
    -> Dict String Param
    -> Dict ChannelNumber String
    -> Dict ChannelNumber String
    -> ID
    -> Node
createCustomNode nodeType params inputs outputs id =
    Node
        { id = id
        , nodeType = Custom nodeType
        , params = params
        , inputs = inputs
        , outputs = outputs
        }
