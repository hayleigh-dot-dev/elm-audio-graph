module AudioGraph exposing
    ( AudioGraph(..), emptyAudioGraph
    , Node(..), NodeType(..), Param(..)
    , Connection, connectionFrom
    , addNode, getNode, removeNode, addConnection, removeConnection
    , createOscillatorNode, createGainNode, createCustomNode
    , getNodeID, getNodeType, getNodeParam, setNodeParam
    )

{-| Info about the library.


# Definition

@docs AudioGraph, emptyAudioGraph


# Types

@docs Node, NodeType, Param, Connection


# Graph Manipulations

@docs addNode, getNode, removeNode, addConnection, removeConnection


# Node Constructors

@docs createOscillatorNode, createGainNode, createCustomNode


# Node Methods

@docs getNodeID, getNodeType, getNodeParam, setNodeParam

-}

import AudioGraph.NodeID as NodeID exposing (NodeID)
import AudioGraph.Units exposing (..)
import Dict exposing (Dict)
import Json.Encode


{-| An `AudioGraph` represents the structure of a Web Audio processing
graph. It is very similar to the Graph Object Model available in the
[Soundstage][https://github.com/soundio/soundstage] javascript package.

A dictionary of [`Node`](#Node)s stores all the currently registered graph
nodes (more on those later), and a separate list tracks how Nodes are connected
to one another.

Typically you won't need to create more than one AudioGraph.

-}
type AudioGraph
    = AudioGraph
        { nodes : Dict String Node
        , connections : List Connection
        }


{-| To construct an Audio Graph, start with the `emptyAudioGraph` which has no
tracked connections and a singular `Output` node. The Output node represents
the Web Audio context _destination_ and has a pre-defined `NodeID` of "\_output".

    type alias Model =
        AudioGraph

    init : Model
    init =
        emptyAudioGraph

-}
emptyAudioGraph : AudioGraph
emptyAudioGraph =
    AudioGraph
        { nodes =
            Dict.fromList
                [ ( NodeID.toString <| getNodeID desintationNode, desintationNode )
                ]
        , connections = []
        }



-- TYPES


{-| `Node` represents a generic audio node.
-}
type Node
    = Node
        { id : NodeID
        , nodeType : NodeType
        , params : Dict String Param
        }


{-| Based on a Nodes params, we can give it a type. This package has built
in types for the most common Web Audio nodes, but the `Custom` type allows
you to [build your own nodes](#createCustomNode).
-}
type NodeType
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


{-| -}
type alias Connection =
    ( (NodeID, String), (NodeID, String) )


{-| -}
connectionFrom : NodeID -> String -> NodeID -> String -> Connection
connectionFrom outputNode outputChannel inputNode inputParam =
    ( (outputNode, outputChannel), (inputNode, inputParam) )


-- GRAPH MANIPULATIONS


{-| Insert a new node into the audio graph. Returns a new audio graph with the
added node.

Note: This will replace an existing node of the same NodeID.
-}
addNode : Node -> AudioGraph -> AudioGraph
addNode node graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.insert (NodeID.toString <| getNodeID node) node g.nodes }


{-| Look up a node in the audio graph by NodeID. Returns `Just Node` if found or
`Nothing` if not.
-}
getNode : NodeID -> AudioGraph -> Maybe Node
getNode id graph =
    case graph of
        AudioGraph g ->
            Dict.get (NodeID.toString id) g.nodes


{-| Remove a node from the audio graph. This is a NoOp if no node with the supplied
NodeID exists in the graph. Returns a new audio graph with the matching node 
removed.
-}
removeNode : NodeID -> AudioGraph  -> AudioGraph
removeNode node graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.remove (NodeID.toString node) g.nodes }


{-| -}
addConnection : Connection -> AudioGraph -> AudioGraph
addConnection connection graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | connections = connection :: g.connections }


{-| -}
removeConnection : Connection -> AudioGraph -> AudioGraph
removeConnection connection graph =
    case graph of
        AudioGraph g ->
            List.filter (\c -> not (c == connection)) g.connections
                |> (\connections -> AudioGraph { g | connections = connections })



-- NODE CONSTRUCTORS


desintationNode : Node
desintationNode =
    Node
        { id = NodeID.fromString "_destination"
        , nodeType = Destination
        , params = Dict.fromList
            [ ( "->0", Input 0 )
            , ( "->1", Input 1 )
            ]
        }


{-| -}
createOscillatorNode : NodeID -> Node
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
createGainNode : NodeID -> Node
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
parameters. Finally, passing a NodeID as usual will construct the new custom
node.

You can then partially apply `createCustomNode` to create your own node generators:

    createMyAwesomeNode : NodeID -> Node
    createMyAwesomeNode id =
        createCustomNode
            "MyAwesomeNode" -- NodeType
            (Dict.fromList  -- Params
                [ ( "->0", Input 0 )
                , ( "awesomeness", Value 100.0 )
                , ( "0->", Output 0 )
                ])
            id -- NodeID

-}
createCustomNode : String -> Dict String Param -> NodeID -> Node
createCustomNode nodeType params id =
    Node
        { id = id
        , nodeType = Custom nodeType
        , params = params
        }



-- NODE METHODS


{-| -}
getNodeID : Node -> NodeID
getNodeID node =
    case node of
        Node a ->
            a.id


{-| -}
getNodeType : Node -> NodeType
getNodeType node =
    case node of
        Node a ->
            a.nodeType


{-| -}
getNodeParam : String -> Node -> Maybe Param
getNodeParam param node =
    case node of
        Node a ->
            Dict.get param a.params


{-| -}
setNodeParam : String -> Param -> Node -> Node
setNodeParam param val node =
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