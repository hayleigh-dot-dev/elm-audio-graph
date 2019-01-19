import Browser
import Html exposing (Html, pre, text)
import Html.Events exposing (onClick)
import Json.Encode exposing (encode)

import AudioGraph exposing (..)
import AudioGraph.NodeID as NodeID exposing (NodeID)
import AudioGraph.Units exposing (..)
import AudioGraph.Encode exposing (encodeAudioGraph)

main =
  Browser.sandbox { init = init, update = update, view = view }

init =
  emptyAudioGraph
    |> addNode (createOscillatorNode (NodeID.fromString "oscA")
      |> setNodeParam "frequency" (Frequency 220)
      |> setNodeParam "detune" (Value 1.5)
      |> setNodeParam "waveform" (Waveform "square"))
    |> addNode (createOscillatorNode (NodeID.fromString "oscB")
      |> setNodeParam "frequency" (Frequency 440)
      |> setNodeParam "waveform" (Waveform "sine"))
    |> addNode (createGainNode (NodeID.fromString "gain")
      |> setNodeParam "gain" (Value 0.5))
    |> addConnection 
      (connectionFrom (NodeID.fromString "oscA") "0->" (NodeID.fromString "oscB") "frequency")
    |> addConnection
      (connectionFrom (NodeID.fromString "oscB") "0->" (NodeID.fromString "_destination") "->0")
    |> addConnection
      (connectionFrom (NodeID.fromString "oscB") "0->" (NodeID.fromString "_destination") "->1")

type Msg = Reset

update msg model =
  case msg of
    Reset -> emptyAudioGraph

view model =
  pre [] [ text <| encode 2 <| encodeAudioGraph model ]