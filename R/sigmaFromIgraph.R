#' Make a basic Sigma graph object from an igraph object
#'
#' @param graph An igraph object
#' @param layout The output of one of the igraph layout functions.  If not provided, layout_nicely() will be used (note, this will slow things down).
#'
#' @import htmlwidgets
#' @export

sigmaFromIgraph <- function(graph, layout = NULL, width = NULL, height = NULL, elementId = NULL){
  edges <- igraph::as_data_frame(graph, what = 'edges')
  edges <- edges[, c('from', 'to')]
  edges$id <- 1:nrow(edges)
  edges$size <- 1
  edges$from <- as.character(edges$from)
  edges$to <- as.character(edges$to)
  colnames(edges) <- c('source','target', 'id','size')
  if(length(layout) == 0){
    l <- igraph::layout_nicely(graph)
  } else {
    l <- layout
  }
  nodes <- igraph::as_data_frame(graph, what = 'vertices')
  nodes$label <- row.names(nodes)
  nodes <- nodes[,'label', drop = FALSE]
  nodes <- cbind(nodes, l)
  colnames(nodes) <- c('label',"x", "y")
  nodes$id <- 1:nrow(nodes)
  nodes$size <- 1
  nodes$x <- as.numeric(nodes$x)
  nodes$y <- as.numeric(nodes$y)
  
  nodes$oldLabs <- row.names(nodes)
  
  edges <- dplyr::left_join(edges, nodes, by = c('source' = 'oldLabs'))
  edges <- dplyr::select(edges, id = id.x, source = id.y, target, size = size.x)
  edges <- dplyr::left_join(edges, nodes, by = c('target' = 'oldLabs'))
  edges <- dplyr::select(edges, id = id.x, source, target = id.y, size = size.x)
  
  nodes$oldLabs <- NULL
  nodes$label <- as.character(nodes$label)
  edges$source <- as.character(edges$source)
  edges$target <- as.character(edges$target)

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')
  
  options <- list(minNodeSize = 1, maxNodeSize = 3, minEdgeSize = 3, maxEdgeSize = 1, nodeColor = "#3182bd", edgeColor = "#636363")
  
  out <- jsonlite::toJSON(graphOut, pretty = TRUE)
  x <- list(data = out, options = options, graph = graph)
  
  htmlwidgets::createWidget(name='sigmaNet', x, width = width, height = height, package = 'sigmaNet', elementId = elementId)
  
}

