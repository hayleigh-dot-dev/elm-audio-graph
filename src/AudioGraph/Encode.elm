module AudioGraph.Encode exposing (encodeAudioGraph, encodeNode)

{-|

@docs encodeAudioGraph, encodeNode

-}

import AudioGraph exposing (..)
import AudioGraph.Node as Node exposing (..)
import Json.Encode as Encode


{-| Encodes the supplied AudioGraph as a Json.Encode.Value. This is necessary when you
want to send the graph through a port and construct the actual Web Audio implementation
in javascript. See the [advanced example](https://github.com/pd-andy/elm-audio-graph/blob/master/examples/Advanced.elm)
for more details on how to do this. -}
encodeAudioGraph : AudioGraph -> Encode.Value
encodeAudioGraph graph =
    case graph of
        AudioGraph g ->
            Encode.object
                [ ( "nodes", Encode.dict identity encodeNode g.nodes )
                , ( "connections", Encode.list encodeConnection g.connections )
                ]


{-| -}
encodeConnection : AudioGraph.Connection -> Encode.Value
encodeConnection ( ( outputNode, outputChannel ), ( inputNode, inputChannel ) ) =
    Encode.object
        [ ( "outputNode", Encode.string <| Node.idToString outputNode )
        , ( "outputChannel", Encode.int outputChannel )
        , ( "inputNode", Encode.string <| Node.idToString inputNode )
        , ( "inputChannel", Encode.int inputChannel )
        ]


{-| Encodes the supplied Node as a Json.Encode.Value. Rarely will you need to use
this directly, but it is exposed for debugging and other fringe cases. -}
encodeNode : Node -> Encode.Value
encodeNode node =
    case node of
        Node a ->
            Encode.object
                [ ( "id", Encode.string <| Node.idToString a.id )
                , ( "type", encodeNodeType a.nodeType )
                , ( "params", Encode.dict identity encodeParam a.params )
                , ( "inputs", Encode.dict identity Encode.int a.inputs )
                , ( "outputs", Encode.dict identity Encode.int a.outputs )
                ]


{-| -}
encodeNodeType : Node.Type -> Encode.Value
encodeNodeType nodeType =
    case nodeType of
        Destination ->
            Encode.string "Destination"

        Oscillator ->
            Encode.string "Oscillator"

        Gain ->
            Encode.string "Gain"

        Custom s ->
            Encode.string s


{-| -}
encodeParam : Node.Param -> Encode.Value
encodeParam param =
    case param of
        Value v ->
            Encode.float v

        Note n ->
            Encode.int n

        Frequency f ->
            Encode.float f

        Waveform s ->
            Encode.string s
