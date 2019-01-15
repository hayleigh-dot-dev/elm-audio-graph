module AudioGraph.NodeID exposing (NodeID, fromString, fromInt, toString)

{-|

@docs NodeID

@docs fromString, fromInt

@docs toString

-}

{-|
-}
type NodeID
    = NodeID String


{-|
-}
fromString : String -> NodeID
fromString id =
    NodeID id


{-|
-}
fromInt : Int -> NodeID
fromInt id =
    NodeID (String.fromInt id)


{-|
-}
toString : NodeID -> String
toString id =
    case id of
      NodeID s -> s