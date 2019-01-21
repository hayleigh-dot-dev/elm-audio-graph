module AudioGraph.Node exposing (
        Node (..)
    ,   ID, idFromString, idFromInt, idToString, getID
    ,   Type, getType
    ,   Param, getParam, setParam
    ,   desintationNode, createOscillatorNode, createGainNode, createCustomNode
    )

{-|

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


-- NODE CONSTRUCTORS


desintationNode : Node
desintationNode =
    Node
        { id = idFromString "_destination"
        , nodeType = Destination
        , params = Dict.fromList
            [ ( "->0", Input 0 )
            , ( "->1", Input 1 )
            ]
        }


{-| -}
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
                , ( "0->", Output 0 )
                ]
        }


{-| -}
createGainNode : ID -> Node
createGainNode id =
    Node
        { id = id
        , nodeType = Gain
        , params =
            Dict.fromList
                [ ( "->0", Input 0 )
                , ( "gain", Value 1.0 )
                , ( "0->", Output 0 )
                ]
        }


{-| You can create your own custom nodes with `createCustomNode` by simply
providing a String to name your new node type, and a dictionary of its default
parameters. Finally, passing a ID as usual will construct the new custom
node.

You can then partially apply `createCustomNode` to create your own node generators:

    createMyAwesomeNode : ID -> Node
    createMyAwesomeNode id =
        createCustomNode
            "MyAwesomeNode" -- Type
            (Dict.fromList  -- Params
                [ ( "->0", Input 0 )
                , ( "awesomeness", Value 100.0 )
                , ( "0->", Output 0 )
                ])
            id -- ID

-}
createCustomNode : String -> Dict String Param -> ID -> Node
createCustomNode nodeType params id =
    Node
        { id = id
        , nodeType = Custom nodeType
        , params = params
        }



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