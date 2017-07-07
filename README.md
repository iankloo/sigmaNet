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

Currently, you can only create graphs from igraph objects:

```
sigmaNet(graph = igraphObject)
```

## Features in development

- Make graphs from edges/nodes data frames
- Be able to change node and edge colors
- Choose between webgl and canvas
- Option for edge size/opacity
- Make all igraph layouts available
- Shiny support
