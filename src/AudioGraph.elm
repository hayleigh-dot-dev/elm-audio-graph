module AudioGraph exposing
    ( AudioGraph(..), emptyAudioGraph
    , Node(..), NodeType(..), Param(..), Connection
    , addNode, getNode, removeNode, addConnection, removeConnection
    , createOscillatorNode, createGainNode, createCustomNode
    , getNodeID, getNodeParam, setNodeParam
    , getNodeType
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
                [ ( NodeID.toString <| getNodeID desintationNode, desintationNode ) ]
        , connections = []
        }



-- TYPES


{-| `Node` represents a generic audio node.
-}
type Node
    = Node { id : NodeID, type_ : NodeType, params : Dict String Param }


{-| Based on a Nodes params, we can give it a type. This package has built
in types for the most common Web Audio nodes, but the `Custom` type allows
you to [build your own nodes](#createCustomNode).
-}
type NodeType
    = Output
    | Oscillator
    | Gain
    | Custom String


{-| -}
type Param
    = Value Float       -- Represents any arbitrary control value
    | Note Int          -- MIDI note number
    | Frequency Float   -- Frequency in Hz
    | Waveform String   -- Oscillator waveform. Is be an arbitrary string.

{-| -}
type alias Connection =
    ( NodeID, NodeID, String )



-- GRAPH MANIPULATIONS


{-| -}
addNode : Node -> AudioGraph -> AudioGraph
addNode node graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.insert (NodeID.toString <| getNodeID node) node g.nodes }


{-| -}
getNode : AudioGraph -> NodeID -> Maybe Node
getNode graph id =
    case graph of
        AudioGraph g ->
            Dict.get (NodeID.toString id) g.nodes


{-| -}
removeNode : AudioGraph -> NodeID -> AudioGraph
removeNode graph node =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.remove (NodeID.toString node) g.nodes }


{-| -}
addConnection : Maybe Node -> Maybe Node -> String -> AudioGraph -> AudioGraph
addConnection outputNode inputNode param graph =
    case graph of
        AudioGraph g ->
            case ( outputNode, inputNode ) of
                ( Just (Node o), Just (Node i) ) ->
                    AudioGraph { g | connections = ( o.id, i.id, param ) :: g.connections }

                _ ->
                    AudioGraph g


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
    Node { id = NodeID.fromString "_output", type_ = Output, params = Dict.empty }


{-| -}
createOscillatorNode : NodeID -> Node
createOscillatorNode id =
    Node
        { id = id
        , type_ = Oscillator
        , params =
            Dict.fromList
                [ ( "detune", Value 0.0 )
                , ( "frequency", Frequency 440.0 )
                , ( "waveform", Waveform "sine" )
                ]
        }


{-| -}
createGainNode : NodeID -> Node
createGainNode id =
    Node
        { id = id
        , type_ = Gain
        , params =
            Dict.fromList
                [ ( "gain", Value 1.0 ) ]
        }


{-| You can create your own custom nodes with `createCustomNode` by simply
providing a String to name your new node type, and a dictionary of its default
parameters. Finally, passing a NodeID as usual will construct the new custom
node.

You can then partially apply `createCustomNode` to create your own node generators:

    createMyAwesomeNode : NodeID -> Node
    createMyAwesomeNode id =
        createCustomNode 
            "MyAwesomeNode"
            (Dict.fromList [ ( "awesomeness", Value 100.0 ) ])

-}
createCustomNode : String -> Dict String Param -> NodeID -> Node
createCustomNode type_ params id =
    Node
        { id = id
        , type_ = Custom type_
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
            a.type_


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
