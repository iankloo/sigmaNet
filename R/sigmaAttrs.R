#' Modify the node colors of a 'sigmaNet' object.
#'
#' Modify the node colors in an existing 'sigmaNet' object by providing one of the following:
#' (1) a single color to use for all nodes or; (2) a vertex attribute from your original
#' 'igraph' object.  If you are using a vertex attribute, you can also specify a color palette
#' from the 'RColorBrewer' package.
#'
#' *It is most useful to use the pipe operator from the 'magrittr' package with this function.
#'
#' @param sigmaObj A 'sigmaNet' object - created using the 'sigmaFromIgraph' function
#' @param oneColor A single color to color all of the nodes (hex format)
#' @param colorAttr An attribute from the original 'igraph' nodes to color the nodes by
#' @param colorPal The color palatte to use - only used if colorAttr is specified
#'
#' @return A 'sigmaNet' object with modified node colors.  This object can be called directly
#'   to create a visualization, or modified by additional functions.
#'
#' @examples
#' library(igraph)
#' library(sigmaNet)
#' library(magrittr)
#'
#' data(lesMis)
#'
#' l <- layout_nicely(lesMis)
#'
#' #one color for all nodes
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addNodeColors(oneColor = '#D95F02')
#' sig
#'
#' #color based on attribute (edge betweenness cluster)
#' clust <- cluster_edge_betweenness(lesMis)$membership
#' V(lesMis)$group <- clust
#'
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addNodeColors(colorAttr = 'group', colorPal = 'Set1')
#' sig
#'
#' @export
addNodeColors <- function(sigmaObj, oneColor = NULL, colorAttr = NULL, colorPal = 'Dark2'){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  if(is.null(oneColor)){
    #nodes$tempCol <- igraph::as_data_frame(sigmaObj$x$graph, what = 'vertices')[,colorAttr]
    nodes$tempCol <- sigmaObj$x$graph$vertices[,colorAttr]

    # If there are more node colors than colors in the chosen palette, interpolate colors to expand the palette
    pal <- tryCatch(RColorBrewer::brewer.pal(length(unique(nodes[,'tempCol'])), colorPal),
      warning = function(w) (grDevices::colorRampPalette(RColorBrewer::brewer.pal(8, colorPal))(length(unique(nodes[,'tempCol'])))))

    palDF <- data.frame(group = unique(nodes[,'tempCol']), color = pal[1:length(unique(nodes[,'tempCol']))], stringsAsFactors = FALSE)
    nodes$color <- palDF$color[match(nodes$tempCol, palDF$group)]
    nodes$tempCol <- NULL
  } else{
    nodes$color <- oneColor
  }

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  sigmaObj$x$data <- jsonlite::toJSON(graphOut, pretty = TRUE)
  return(sigmaObj)
}
#' Modify the node size of a 'sigmaNet' object.
#'
#' Modify the node size of an existing 'sigmaNet' object by providing one of the following:
#' (1) A single size to use for all nodes; (2) a vector of node sizes (this must be the same
#' length as the number of nodes in the graph); or (3) a metric to use to scale the nodes.
#'
#' If using the 2nd or 3rd approach, specifying the minSize and maxSize attributes will scale
#' the nodes according to your specification, between these min- and max sizes.
#'
#' @param sigmaObj A 'sigmaNet' object - created using the 'sigmaFromIgraph' function
#' @param minSize The minimum node size on the graph (for scaling)
#' @param maxSize The maximum node size on the graph (for scaling)
#' @param sizeMetric The metric to use when sizing the nodes.  Options are: degree, closeness, betweenness, pageRank, or eigenCentrality.
#' @param sizeVector An optional vector with the sizes for each node (overrides sizeMetric and min/maxSize)
#' @param oneSize A single size to use for all nodes
#'
#' @return A 'sigmaNet' object with modified node sizes  This object can be called directly
#'   to create a visualization, or modified by additional functions.
#'
#' @examples
#' library(igraph)
#' library(sigmaNet)
#' library(magrittr)
#'
#' data(lesMis)
#'
#' l <- layout_nicely(lesMis)
#'
#' #one size for all nodes
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addNodeSize(oneSize = 3)
#' sig
#'
#' #using a size attribute
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addNodeSize(sizeMetric = 'degree', minSize = 2, maxSize = 8)
#' sig
#'
#' #using a vector
#' customSize <- log10(degree(lesMis))
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'  addNodeSize(sizeVector = customSize)
#' sig
#'
#' @export
addNodeSize <- function(sigmaObj, minSize = 1, maxSize = 3, sizeMetric = 'degree', sizeVector = NULL, oneSize = NULL){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  if(!is.null(oneSize)){
    nodes$size <- oneSize
    sigmaObj$x$options$minNodeSize <- oneSize
    sigmaObj$x$options$maxNodeSize <- oneSize
  } else if(!is.null(sizeVector)){
    nodes$size <- sizeVector
    sigmaObj$x$options$minNodeSize <- minSize
    sigmaObj$x$options$maxNodeSize <- maxSize
  } else{
    tmp_graph <- igraph::graph_from_data_frame(sigmaObj$x$graph$edges)
    if(sizeMetric == 'degree'){
      nodes$size <- igraph::degree(tmp_graph)
    } else if(sizeMetric == 'closeness'){
      nodes$size <- igraph::closeness(tmp_graph)
    } else if(sizeMetric == 'betweenness'){
      nodes$size <- igraph::betweenness(tmp_graph)
    } else if(sizeMetric == 'pageRank'){
      nodes$size <- igraph::page_rank(tmp_graph)$vector
    } else if(sizeMetric == 'eigenCentrality'){
      nodes$size <- igraph::eigen_centrality(tmp_graph)$vector
    } else{
      stop('sizeMetric can only be one of: degree, closeness, betweenness, pageRank, or eigenCentrality.')
    }
    sigmaObj$x$options$minNodeSize <- minSize
    sigmaObj$x$options$maxNodeSize <- maxSize
  }

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  sigmaObj$x$data <- jsonlite::toJSON(graphOut, pretty = TRUE)
  return(sigmaObj)

}
#' Modify the node labels of a 'sigmaNet' object.
#'
#' Modify the node labels of an existing 'sigmaNet' object by providing an attribute from the
#' initial 'igraph' to use as the labels.
#'
#' @param sigmaObj A 'sigmaNet' object - created using the 'sigmaFromIgraph' function
#' @param labelAttr The attribute to use to create node labels
#'
#' @return A 'sigmaNet' object with modified node labels.  This object can be called directly
#'   to create a visualization, or modified by additional functions.
#'
#' @examples
#' library(igraph)
#' library(sigmaNet)
#' library(magrittr)
#'
#' data(lesMis)
#'
#' l <- layout_nicely(lesMis)
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addNodeLabels(labelAttr = 'label')
#' sig
#'
#' @export
addNodeLabels <- function(sigmaObj, labelAttr = NULL){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  #nodes$label <- as.character(igraph::as_data_frame(sigmaObj$x$graph, what = 'vertices')[,labelAttr])
  nodes$label <- as.character(sigmaObj$x$graph$vertices[,labelAttr])

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  sigmaObj$x$data <- jsonlite::toJSON(graphOut, pretty = TRUE)
  return(sigmaObj)
}
#' Modify the edge size of a 'sigmaNet' object.
#'
#' Modify the edge size of a 'sigmaNet' object by providing one of the following: (1) a single size
#' to use for all edges; or (2) an attribute in the initial igraph to be used to size the edges.
#'
#' If the 2nd method is used, the minSize and maxSize attribute will control lower and upper bounds
#' of the scaling function.
#'
#' @param sigmaObj A 'sigmaNet' object - created using the 'sigmaFromIgraph' function
#' @param sizeAttr The attribute to use to create edge size (width)
#' @param minSize The minimum size of the edges (for scaling)
#' @param maxSize The maximum size of the edges (for scaling)
#' @param oneSize A single size to use for all edges
#'
#' @return A 'sigmaNet' object with modified node labels.  This object can be called directly
#'   to create a visualization, or modified by additional functions.
#'
#' @examples
#' library(igraph)
#' library(sigmaNet)
#' library(magrittr)
#'
#' data(lesMis)
#'
#' l <- layout_nicely(lesMis)
#'
#' #specify a single edge size
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addEdgeSize(oneSize = 5)
#' sig
#'
#' #specify an attribute and min/max
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addEdgeSize(sizeAttr = 'value', minSize = .1, maxSize = 2)
#' sig
#'
#' @export
addEdgeSize <- function(sigmaObj, sizeAttr = NULL, minSize = 1, maxSize = 5, oneSize = NULL){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  if(!is.null(oneSize)){
    edges$size <- oneSize
    sigmaObj$x$options$minEdgeSize <- oneSize
    sigmaObj$x$options$maxEdgeSize <- oneSize
  } else{
    #edges$size <- as.character(igraph::as_data_frame(sigmaObj$x$graph, what = 'edges')[,sizeAttr])
    edges$size <- as.character(sigmaObj$x$graph$edges[,sizeAttr])
    sigmaObj$x$options$minEdgeSize <- minSize
    sigmaObj$x$options$maxEdgeSize <- maxSize
  }

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  sigmaObj$x$data <- jsonlite::toJSON(graphOut, pretty = TRUE)
  return(sigmaObj)
}
#' Modify the edge colors of a 'sigmaNet' object.
#'
#' Modify the edge colors of a 'sigmaNet' object by providing either: (1) a single color to use
#' for every edge; or (2) an attribute of the initial 'igraph' object that will be used to determine
#' color.
#'
#' If the 2nd option is used, you can also specify a color palette from 'RColorBrewer.'
#'
#' @param sigmaObj A 'sigmaNet' object - created using the 'sigmaFromIgraph' function
#' @param oneColor A single color to color all of the nodes (hex format)
#' @param colorAttr An attribute from the original 'igraph' nodes to color the nodes by
#' @param colorPal The color palatte to use - only used if colorAttr is specified
#'
#' @return A 'sigmaNet' object with modified node labels.  This object can be called directly
#'   to create a visualization, or modified by additional functions.
#'
#' @examples
#' library(igraph)
#' library(sigmaNet)
#' library(magrittr)
#'
#' data(lesMis)
#'
#' l <- layout_nicely(lesMis)
#'
#' #one color for all edges
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addEdgeColors(oneColor = '#D95F02')
#' sig
#'
#' @export
addEdgeColors <- function(sigmaObj, oneColor = NULL, colorAttr = NULL, colorPal = 'Set2'){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  if(is.null(oneColor)){
    #edges$tempCol <- igraph::as_data_frame(sigmaObj$x$graph, what = 'edges')[,colorAttr]
    edges$tempCol <- sigmaObj$x$graph$edges[,colorAttr]

    # If there are more edge colors than colors in the chosen palette, interpolate colors to expand the palette
    pal <- tryCatch(RColorBrewer::brewer.pal(length(unique(edges[,'tempCol'])), colorPal),
      warning = function(w) (grDevices::colorRampPalette(RColorBrewer::brewer.pal(8, colorPal))(length(unique(edges[,'tempCol'])))))

    palDF <- data.frame(group = unique(edges[,'tempCol']), color = pal[1:length(unique(edges[,'tempCol']))], stringsAsFactors = FALSE)
    edges$color <- palDF$color[match(edges$tempCol, palDF$group)]
    edges$tempCol <- NULL
  } else{
    edges$color <- oneColor
  }

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  sigmaObj$x$data <- jsonlite::toJSON(graphOut, pretty = TRUE)
  return(sigmaObj)
}
#' Save 'sigmaNet' object as html - a wrapper for saveWidget()
#'
#' Save an 'sigmaNet' object as an html file (without rendering it).  This is especially helpful
#' when dealing with very large graphs that could crash your R session if you attempt to render
#' them in the 'Rstudio' viewer pane.
#'
#' @param sigmaObj A 'sigmaNet' object - created using the 'sigmaFromIgraph' function
#' @param fileName A name for your html output (with or without .html at the end)
#'
#' @return An html file in your working directory (or other specified directory).  This file is a
#'   standalone representation of your 'Sigma.js' visualization that can be shared and moved freely.
#'   This object will maintain it's interactivity.
#'
#' @examples
#' library(igraph)
#' library(sigmaNet)
#' library(magrittr)
#'
#' data(lesMis)
#'
#' l <- layout_nicely(lesMis)
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l)
#'
#' \dontrun{
#' saveSigma(sig, fileName = file.path(tempdir(), 'myFile.html'))
#' }
#'
#' @export
saveSigma <- function(sigmaObj, fileName = NULL){
  if(is.null(fileName)){
    stop('Please provide a file name')
  }
  if(length(grep('\\.html', fileName)) == 0){
    fileName <- paste0(fileName, '.html')
  }
  htmlwidgets::saveWidget(sigmaObj, file = fileName)
}
#' Modify the interactivity of a 'sigmaNet' object.
#'
#' Modify the interactivity of a 'sigmaNet' object using the below options.  By default, visualizations
#' include on-click neighbor events, double-click zoom, and mouse-wheel zoom.  These can all be disabled
#' or modified per the below options.
#'
#' @param sigmaObj A 'sigmaNet' object - created using the 'sigmaFromIgraph' function
#' @param neighborEvent Enable/disable event that highlights a node's neighbors.  Can either be onClick, onHover, or None.
#' @param doubleClickZoom Enable/disable zoom event on double click
#' @param mouseWheelZoom Enable/disable zoom event on mouse wheel
#'
#' @examples
#' library(igraph)
#' library(sigmaNet)
#' library(magrittr)
#'
#' data(lesMis)
#'
#' l <- layout_nicely(lesMis)
#' #change neighbor highlighting to on-hover, disable double-click zoom, enable mouse-wheel zoom
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l) %>%
#'   addInteraction(neighborEvent = 'onHover', doubleClickZoom = FALSE, mouseWheelZoom = TRUE)
#' sig
#'
#' @export
addInteraction <- function(sigmaObj, neighborEvent = 'onClick', doubleClickZoom = TRUE, mouseWheelZoom = TRUE){
  if(neighborEvent == 'onClick'){
    sigmaObj$x$options$neighborStart <- 'clickNode'
    sigmaObj$x$options$neighborEnd <- 'clickStage'
  } else if(neighborEvent == 'onHover'){
    sigmaObj$x$options$neighborStart <- 'overNode'
    sigmaObj$x$options$neighborEnd <- 'outNode'
  }
  sigmaObj$x$options$neighborEvent <- neighborEvent

  sigmaObj$x$options$doubleClickZoom <- doubleClickZoom
  sigmaObj$x$options$mouseWheelZoom <- mouseWheelZoom

  return(sigmaObj)
}
#' Add a "listener" to report data from a 'sigmaNet' object in 'Shiny' back to the R session.
#'
#' @param sigmaObj A 'sigmaNet' object - created using the 'sigmaFromIgraph' function
#' @param listener Either "clickNode" to listen to node clicks or "hoverNode" to listen to node hover
#'
#' @export
addListener <- function(sigmaObj, listener){
  sigmaObj$x$options$sigmaEvents <- listener
  return(sigmaObj)
}
