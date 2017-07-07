# sigmaNet

IN DEVELOPMENT

This is an attempt at an htmlwidget connecting R and sigma js.  While there is already a pre-existing library called sigma, this one is meant to be more full featured (the original library was built as a demonstration of the htmlwidgets framework and is no longer being developed).

## Advantages over existing Sigma htmlwidget

1. No need to create external file before rendering (which can complicate implementation in server-side shiny apps)
2. Remove rgexf dependency
3. More intuitive to make graphs in R workflow (no need to learn what a gexf object should look like)
4. More control over graph attributes: color, size, opacity, etc. of edges/nodes
5. Choose between webgl and canvas
6. Bring the graph learning algorithms (from igraph) and graph drawing via sigma into one place


## Basic network rendering

Currently, the sigmaNet function takes an igraph object and outputs a Simga js widget:
```
sigmaNet(graph = igraphObject)
```

There are a few options:

```
sigmaNet(graph = igraphObject, minNodeSize = 1, maxNodeSize = 8, minEdgeSize = 1, maxEdgeSize = 1, nodeColor = 'blue', edgeColor = 'black')
```
Note, edge and node colors can be set as a color string or a hex string.

The edge size attributes are particularly useful when drawing large graphs.  These act as defacto alpha (opacity) attributes - which is necessary because alpha is not available in the Sigma webgl renderer.  If you find that your edges are creating a messy graph, try setting them to be very small (say, 0.05).

## Features in development

- Make graphs from edges/nodes data frames
- Choose between webgl and canvas
- Make all igraph layouts available
- Shiny support
- Base node size on things other than degree
