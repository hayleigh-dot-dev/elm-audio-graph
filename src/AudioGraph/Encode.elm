module AudioGraph.Encode exposing (encodeAudioGraph, encodeNode)

{-|

@docs encodeAudioGraph, encodeNode

-}

import AudioGraph exposing (..)
import AudioGraph.Node exposing (..)
import Json.Encode as Encode


{-| -}
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
encodeConnection ((outputNode, outputChannel), (inputNode, inputParam)) =
    Encode.object
        [ ( "output", Encode.string <| NodeID.toString outputNode )
        , ( "outputChannel", Encode.string outputChannel)
        , ( "input", Encode.string <| NodeID.toString inputNode )
        , ( "param", Encode.string inputParam )
        ]


{-| -}
encodeNode : Node -> Encode.Value
encodeNode node =
    case node of
        Node a ->
            Encode.object
                [ ( "id", Encode.string <| NodeID.toString a.id )
                , ( "type", encodeNodeType a.nodeType )
                , ( "params", Encode.dict identity encodeParam a.params )
                ]


{-| -}
encodeNodeType : NodeType -> Encode.Value
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
encodeParam : Param -> Encode.Value
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

        Input i ->
            Encode.int i

        Output o ->
            Encode.int o
