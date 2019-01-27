module AudioGraph.Node exposing
    ( Node(..)
    , ID, idFromString, idFromInt, idToString, Type(..), Param(..)
    , getID, getType, getParam, setParam
    , desintationNode, createOscillatorNode, createGainNode, createCustomNode
    , getInputFromLabel, getOutputFromLabel
    )

{-|


# Definition

@docs Node


# Types

@docs ID, idFromString, idFromInt, idToString, Type, Param


# Node Methods

@docs getID, getType, getParam, setParam, getInputFromLabel, getOutputFromLabel


# Node Constructors

@docs desintationNode, createOscillatorNode, createGainNode, createCustomNode

-}

import AudioGraph.Units exposing (..)
import Dict exposing (Dict)


{-| Node represents a generic audio node. 
-}
type Node
    = Node
        { id : ID
        , nodeType : Type
        , params : Dict String Param
        , inputs : Dict String ChannelNumber
        , outputs : Dict String ChannelNumber
        }


{-| A NodeID is used to ensure each node in the graph is unique. This is necessary
if you're tracking changes to the graph in javascript when constructing and updating
an actual Web Audio graph.

This package does not provide a means of generating NodeIDs, you are free to use
other packages and convert the results to a NodeID with the `idFromString` and
`idFromInt` methods. You may also simply use human readable NodeIDs such as `myOsc`.
-}
type ID
    = ID String


{-| Takes a raw string and returns a NodeID. -}
idFromString : String -> ID
idFromString id =
    ID id


{-| Takes any integer and returns a NodeID. -}
idFromInt : Int -> ID
idFromInt id =
    ID (String.fromInt id)


{-| Converts a NodeID into a raw string. Used when encoding an audio node, but 
may also be useful in your own code. -}
idToString : ID -> String
idToString id =
    case id of
        ID s ->
            s


{-| In order to construct the real Web Audio graph in javascript, we need to know
what each node actually is. Custom types are also supported to allow user-defined
audio nodes to be constructed, or third-party / non-standard Web Audio nodes to 
be represented.
-}
type Type
    = Destination
    | Oscillator
    | Gain
    | Custom String


{-| Node params are typed to restrict their values. This type safety ensures that
if your elm code compiles then a valid audio graph can be constructed in javascript.
The values for each Param are simple type aliases that can be found in [AudioGraph.Units](/AudioGraph.Units)
and exist solely for more expressive type annotations. 

Some utilities for dealing with units can be found in [AudioGraph.Utils](/AudioGraph.Utils).
Currently only conversion to and from `MIDI` / `Hertz` is available.
-}
type Param
    = Value KValue -- Represents any arbitrary control value
    | Note MIDI -- MIDI note number
    | Frequency Hertz -- Frequency in Hz
    | Waveform String -- Oscillator waveform. Is be an arbitrary string.



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


{-| Searches a nodes inputs by label and returns the channel number that matches.
If no match is found, -1 is chosen instead. 
-}
getInputFromLabel : String -> Node -> ChannelNumber
getInputFromLabel label node =
    case node of
        Node a ->
            case Dict.get label a.inputs of
                Just n ->
                    n

                Nothing ->
                    -1


{-| Searches a nodes inputs by label and returns the channel number that matches.
If no match is found, -1 is chosen instead.  
-}
getOutputFromLabel : String -> Node -> ChannelNumber
getOutputFromLabel label node =
    case node of
        Node a ->
            case Dict.get label a.outputs of
                Just n ->
                    n

                Nothing ->
                    -1



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
                [ ( "audioIn_Left", 0 )
                , ( "audioIn_Right", 1 )
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
                [ ( "frequency", 0 )
                , ( "detune", 1 )
                ]
        , outputs =
            Dict.fromList
                [ ( "audioOut", 0 )
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
                [ ( "audioIn", 0 )
                , ( "gain", 1 )
                ]
        , outputs =
            Dict.fromList
                [ ( "audioOut", 0 )
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
                ]
            )
            (Dict.fromList
                [ ( "audioIn", 0 )
                , ( "awesomeness", 1 )
                ]
            )
            (Dict.fromList
                [ ( "audioOut", 0 )
                ]
            )

-}
createCustomNode :
    String
    -> Dict String Param
    -> Dict String ChannelNumber
    -> Dict String ChannelNumber
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
