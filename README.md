# elm-audio-graph

The elm-audio-graph provides a type-safe way of constructing Web Audio node graphs.
It is important to note that this package does not interface with the Web Audio API
directly, but provides methods to serialise the created audio graph to JSON where
your javascript can handle the necessary creation and updating of Web Audio nodes.

### Who?


### Why?


## Basic Example - [Source](/examples/Basic.elm)
The basic example shows how to create a simple audio graph from scratch; the resulting
serialised JSON is then rendered on the page. Below is the main snippet of that example.

The `addNode` and `addConnection` methods return a new updated audio graph and so
can be chained together to quickly construct complex graphs. 

Parameter types are restricted, for example the "frequency" param can only accept
`Frequency Hertz` values. The ensures type safety and reduces the risk of audio
droppouts and unexpected behaviours. 

```elm
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
```

Below is the resulting JSON created when calling `JSON.Encode.encode 2 (encodeAudioGraph graph)`

```json
{
  "nodes": {
    "_destination": {
      "id": "_destination",
      "type": "Destination",
      "params": {},
      "inputs": {
        "audioIn_Left": 0,
        "audioIn_Right": 1
      },
      "outputs": {}
    },
    "gain": {
      "id": "gain",
      "type": "Gain",
      "params": {
        "gain": 0.5
      },
      "inputs": {
        "audioIn": 0,
        "gain": 1
      },
      "outputs": {
        "audioOut": 0
      }
    },
    "oscA": {
      "id": "oscA",
      "type": "Oscillator",
      "params": {
        "detune": 1.5,
        "frequency": 220,
        "waveform": "square"
      },
      "inputs": {
        "detune": 1,
        "frequency": 0
      },
      "outputs": {
        "audioOut": 0
      }
    },
    "oscB": {
      "id": "oscB",
      "type": "Oscillator",
      "params": {
        "detune": 0,
        "frequency": 440,
        "waveform": "sine"
      },
      "inputs": {
        "detune": 1,
        "frequency": 0
      },
      "outputs": {
        "audioOut": 0
      }
    }
  },
  "connections": [
    {
      "outputNode": "oscB",
      "outputChannel": 0,
      "inputNode": "_destination",
      "inputChannel": 1
    },
    {
      "outputNode": "oscB",
      "outputChannel": 0,
      "inputNode": "_destination",
      "inputChannel": 0
    },
    {
      "outputNode": "oscA",
      "outputChannel": 0,
      "inputNode": "oscB",
      "inputChannel": 0
    }
  ]
}
```


## Advanced Example - [Source](/examples/Advanced.elm)
