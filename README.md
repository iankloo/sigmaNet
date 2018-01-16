# sigmaNet

Render igraph networks using Sigma.js - in R!  

<strong>More detailed documentation on the way.</strong>

## Why?

Igraph is a great tool for working with networks in R, but it comes up short when creating visualizations.  Igraph uses R's plot() and a less-than-user-friendly set of parameters to create visualizations.  These visualizations are static and can be difficult to work with aesthetically.  For example, node sizes can be given with the vertex.size parameter, but they are then re-scaled by the plot() function behind the scenes.  Finally, plot() output is static and can only be rendered in image formats.

This package addresses these problems by allowing users to quickly create Sigma.js visualizations from igraph objects.  These visualizations render quickly, even with large numbers of nodes/edges, and allow for a number of different outputs: PNG, PDF, and interactive HTML.  

If you are only working with small networks, check out the visNetwork package which uses vis.js to draw networks.  The package has a lot of great features, but it is somewhat slow for large networks (10s of thousands of nodes) and can be sluggish once rendered.  This is because vis.js (and thus visNetwork) use canvas to render graphs.  Canvas is much faster than SVG-based graphics (like D3), but is slower than Webgl (used by Sigma.js).

## How?

First, install this package:

```
devtools::install_github('iankloo/sigmaNet')
```

Then, create an igraph network.  Here we'll use the sample "Karate" network from the igraphdata package.

Note, passing a layout to the sigmaFromIgraph() function will dramatically improve speed.

```
library(sigmaNet)
library(igraph)
library(igraphdata)

data(karate)
layout <- layout_with_fr(karate)

sigmaFromIgraph(karate, layout = layout)
```
![](simpleNetwork.png)


If you render this at home, you'll see that you can zoom, pan, and get information on-hover for the nodes.

## Options

You have a few options available to change the aesthetics of graphs. Options are applied in a similar way to ggplot, but use the pipe operator instead of the "+".  Here is an example showing most of the options you can use:

(this thing looks terrible if you render it - just showing what options you can change)
```
data(karate)
layout <- layout_with_fr(karate)
sig <- sigmaFromIgraph(karate, layout = layout)

sig %>%
  addNodeColors(colorAttr = 'Faction') %>%
  addNodeSize(sizeMetric = 'degree', minSize = 1, maxSize = 6) %>%
  addNodeLabels(labelAttr = 'Faction') %>%
  addEdgeSize(sizeAttr = 'weight', minSize = .1, maxSize = 5) %>%
  addEdgeColors(colorAttr = 'weight', colorPal = 'Dark2') 
```


Note: there is no opacity/transparency/alpha attribute!  That is because webgl doesn't support transparency.  To mimic transparency, set your edge size to be small - this works really well.  I know this is a big tradeoff, but it is the only way to render large networks without sacrificing performance.  

## Larger Networks

This package was built to address the specific challenges of creating compelling visualizations with large networks.  Here is an example of a larger network than we've been using

```
data(immuno)
layout <- layout_with_fr(immuno)
sig <- sigmaFromIgraph(immuno, layout = layout)
sig %>% 
  addNodeColors('#D95F02') %>%
  addNodeSize(sizeMetric = 'degree', minSize = .001, maxSize = 2) %>%
  addEdgeSize(oneSize = .1)
```
![](bigNetwork.png)

As you can see, this graph still looks great even without transparency.  If you render this at home, you will see that the visualization is still snappy and responsive.  

## Shiny Support

You can use sigmaNet() output in Shiny using renderSigmaNet() in your server and sigmaNetOutput() in your ui.  See the shiny docs for more general info about Shiny - these functions drop-in just like the basic plotting examples.  

## Features in development

- Use different shapes?
- Add neighborhoods plugin
- Add filter plugin
- Options to control interactivity (plugins)
- GUI to modify aesthetics (shiny gadget)



