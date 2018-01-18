#' Add node colors by an attribute or by specifying a single color.
#'
#' @param sigmaObj A Sigma object - created using the sigmaFromIgraph function
#' @param oneColor A single color to color all of the nodes (hex format)
#' @param colorAttr An attribute from the original igraph nodes to color the nodes by
#' @param colorPal The color palatte to use - only used if colorAttr is specified
#'
#' @import htmlwidgets
#' @export
addNodeColors <- function(sigmaObj, oneColor = NULL, colorAttr = NULL, colorPal = 'Dark2'){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  if(is.null(oneColor)){
    nodes$tempCol <- igraph::as_data_frame(sigmaObj$x$graph, what = 'vertices')[,colorAttr]
    suppressWarnings(pal <- RColorBrewer::brewer.pal(length(unique(nodes[,'tempCol'])), colorPal))
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
#' Add node size by either specifying a metric, or supplying your own vector of sizes.
#'
#' @param sigmaObj A Sigma object - created using the sigmaFromIgraph function
#' @param minSize The minimum node size on the graph (for scaling)
#' @param maxSize The maximum node size on the graph (for scaling)
#' @param sizeMetric The metric to use when sizing the nodes.  Options are: degree, closeness, betweenness, pageRank, or eigenCentrality.
#' @param sizeVector An optional vector with the sizes for each node (overrides sizeMetric and min/maxSize)
#' @param oneSize A single size to use for all nodes
#'
#' @import htmlwidgets
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
    if(sizeMetric == 'degree'){
      nodes$size <- igraph::degree(sigmaObj$x$graph)
    } else if(sizeMetric == 'closeness'){
      nodes$size <- igraph::closeness(sigmaObj$x$graph)
    } else if(sizeMetric == 'betweenness'){
      nodes$size <- igraph::betweenness(sigmaObj$x$graph)
    } else if(sizeMetric == 'pageRank'){
      nodes$size <- igraph::page_rank(sigmaObj$x$graph)$vector
    } else if(sizeMetric == 'eigenCentrality'){
      nodes$size <- igraph::eigen_centrality(sigmaObj$x$graph)$vector
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
#' Add node labels by specifying an attribute from the igraph object.
#'
#' @param sigmaObj A Sigma object - created using the sigmaFromIgraph function
#' @param labelAttr The attribute to use to create node labels
#'
#' @import htmlwidgets
#' @export
addNodeLabels <- function(sigmaObj, labelAttr = NULL){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  nodes$label <- as.character(igraph::as_data_frame(sigmaObj$x$graph, what = 'vertices')[,labelAttr])

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  sigmaObj$x$data <- jsonlite::toJSON(graphOut, pretty = TRUE)
  return(sigmaObj)
}
#' Add edge size by specifying an attribute (usually weight) or a single edge size for all edges.
#'
#' @param sigmaObj A Sigma object - created using the sigmaFromIgraph function
#' @param sizeAttr The attribute to use to create edge size (width)
#' @param minSize The minimum size of the edges (for scaling)
#' @param maxSize The maximum size of the edges (for scaling)
#' @param oneSize A single size to use for all edges
#'
#' @import htmlwidgets
#' @export
addEdgeSize <- function(sigmaObj, sizeAttr = NULL, minSize = 1, maxSize = 5, oneSize = NULL){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  if(!is.null(oneSize)){
    edges$size <- oneSize
    sigmaObj$x$options$minEdgeSize <- oneSize
    sigmaObj$x$options$maxEdgeSize <- oneSize
  } else{
    edges$size <- as.character(igraph::as_data_frame(sigmaObj$x$graph, what = 'edges')[,sizeAttr])
    sigmaObj$x$options$minEdgeSize <- minSize
    sigmaObj$x$options$maxEdgeSize <- maxSize
  }

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  sigmaObj$x$data <- jsonlite::toJSON(graphOut, pretty = TRUE)
  return(sigmaObj)
}
#' Add edge colors by an attribute or by specifying a single color.
#'
#' @param sigmaObj A Sigma object - created using the sigmaFromIgraph function
#' @param oneColor A single color to color all of the nodes (hex format)
#' @param colorAttr An attribute from the original igraph nodes to color the nodes by
#' @param colorPal The color palatte to use - only used if colorAttr is specified
#'
#' @import htmlwidgets
#' @export
addEdgeColors <- function(sigmaObj, oneColor = NULL, colorAttr = NULL, colorPal = 'Set2'){
  edges <- jsonlite::fromJSON(sigmaObj$x$data)$edges
  nodes <- jsonlite::fromJSON(sigmaObj$x$data)$nodes

  if(is.null(oneColor)){
    edges$tempCol <- igraph::as_data_frame(sigmaObj$x$graph, what = 'edges')[,colorAttr]
    suppressWarnings(pal <- RColorBrewer::brewer.pal(length(unique(edges[,'tempCol'])), colorPal))
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
#' Save sigma widget as html - a wrapper for saveWidget()
#'
#' @param sigmaObj A Sigma object - created using the sigmaFromIgraph function
#' @param fileName A name for your html output (with or without .html at the end)
#'
#' @import htmlwidgets
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
#' Add/modify interactivity of the visualization
#'
#' @param sigmaObj A Sigma object - created using the sigmaFromIgraph function
#' @param neighborEvent Enable/disable event that highlights a node's neighbors.  Can either be onClick, onHover, or None.
#' @param doubleClickZoom Enable/disable zoom event on double click
#' @param mouseWheelZoom Enable/disable zoom event on mouse wheel
#'
#' @import htmlwidgets
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
