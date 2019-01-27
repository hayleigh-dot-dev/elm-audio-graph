import Browser
import Html exposing (Html, pre, text)
import Json.Encode exposing (encode)

import AudioGraph exposing (..)
import AudioGraph.Node exposing (..)
import AudioGraph.Units exposing (..)
import AudioGraph.Encode exposing (encodeAudioGraph)

main =
  Browser.sandbox { init = init, update = update, view = view }

init =
  emptyAudioGraph
    |> addNode (createOscillatorNode (idFromString "oscA")
      |> setParam "frequency" (Frequency 220)
      |> setParam "detune" (Value 1.5)
      |> setParam "waveform" (Waveform "square"))
    |> addNode (createOscillatorNode (idFromString "oscB")
      |> setParam "frequency" (Frequency 440)
      |> setParam "waveform" (Waveform "sine"))
    |> addNode (createGainNode (idFromString "gain")
      |> setParam "gain" (Value 0.5))
    |> addConnection 
      (connectionFrom (idFromString "oscA") 0 (idFromString "oscB") 0)
    |> addConnection
      (connectionFrom (idFromString "oscB") 0 (idFromString "_destination") 0)
    |> addConnection
      (connectionFrom (idFromString "oscB") 0 (idFromString "_destination") 1)

type Msg = Reset

update msg model =
  case msg of
    Reset -> emptyAudioGraph

view model =
  pre [] [ text <| encode 2 <| encodeAudioGraph model ]