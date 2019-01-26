module AudioGraph exposing
    ( AudioGraph(..), emptyAudioGraph
    , Connection, connectionFrom
    , addNode, getNode, removeNode, addConnection, removeConnection
    )

{-| Info about the library.


# Definition

@docs AudioGraph, emptyAudioGraph


# Types

@docs Connection, connectionFrom


# Graph Manipulations

@docs addNode, getNode, removeNode, addConnection, removeConnection

-}

import AudioGraph.Node as Node exposing (Node(..), desintationNode)
import AudioGraph.Units exposing (..)
import Dict exposing (Dict)
import Json.Encode


{-| An `AudioGraph` represents the structure of a Web Audio processing
graph. It is very similar to the Graph Object Model available in the
[Soundstage](https://github.com/soundio/soundstage) javascript package.

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
the Web Audio context _destination_ and has a pre-defined `Node.ID` of "\_output".

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
                [ ( Node.idToString <| Node.getID desintationNode, desintationNode )
                ]
        , connections = []
        }



-- TYPES


{-| -}
type alias Connection =
    ( ( Node.ID, ChannelNumber ), ( Node.ID, ChannelNumber ) )


{-| -}
connectionFrom : Node.ID -> ChannelNumber -> Node.ID -> ChannelNumber -> Connection
connectionFrom outputNode outputChannel inputNode inputChannel =
    ( ( outputNode, outputChannel )
    , ( inputNode, inputChannel ) )



-- GRAPH MANIPULATIONS


{-| Insert a new node into the audio graph. Returns a new audio graph with the
added node.

Note: This will replace an existing node of the same Node.ID.

-}
addNode : Node -> AudioGraph -> AudioGraph
addNode node graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.insert (Node.idToString <| Node.getID node) node g.nodes }


{-| Look up a node in the audio graph by Node.ID. Returns `Just Node` if found or
`Nothing` if not.
-}
getNode : Node.ID -> AudioGraph -> Maybe Node
getNode id graph =
    case graph of
        AudioGraph g ->
            Dict.get (Node.idToString id) g.nodes


{-| Remove a node from the audio graph. This is a NoOp if no node with the supplied
Node.ID exists in the graph. Returns a new audio graph with the matching node
removed.
-}
removeNode : Node.ID -> AudioGraph -> AudioGraph
removeNode node graph =
    case graph of
        AudioGraph g ->
            AudioGraph { g | nodes = Dict.remove (Node.idToString node) g.nodes }


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
