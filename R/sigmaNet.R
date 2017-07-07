#' Draw a network in sigmajs
#' 
#' @param graph An igraph object
#' @param minNodeSize The minimum size of graph nodes (defaults to 1)
#' @param maxNodeSize The maximum size of graph nodes (defaults to 8)
#' @param minEdgeSize The minimum size of graph edges (defaults to 1)
#' @param maxEdgeSize The maxiumum size of graph edges (defaults to 1)
#' @param nodeColor A color name or hex string specifying the color for all nodes
#' @param edgeColor A color name of hex string specifying the color for all edges
#' 
#' 
#' @import htmlwidgets
#' @export

sigmaNet <- function(graph, minNodeSize = 1, maxNodeSize = 8, minEdgeSize = 1, maxEdgeSize = 1, nodeColor = "#3182bd", edgeColor =  "#636363", width = NULL, height = NULL, elementId = NULL){
  edges <- as.data.frame(igraph::get.edgelist(graph), stringsAsFactors = FALSE)
  edges$id <- 1:nrow(edges)
  edges$size <- 1
  colnames(edges) <- c('source','target','id','size')
  
  l <- igraph::layout_with_fr(graph, grid = 'nogrid')
  
  nodes <- igraph::V(graph)$name
  if(is.null(nodes)){
    nodes <- 1:length(igraph::V(graph))
  }
  nodes <- cbind(nodes, l)
  nodes <- as.data.frame(nodes, stringsAsFactors = FALSE)
  colnames(nodes) <- c('label',"x", "y")
  nodes$id <- 1:nrow(nodes)
  nodes$size <- igraph::degree(graph)
  nodes$x <- as.numeric(nodes$x)
  nodes$y <- as.numeric(nodes$y)
  
  edges <- dplyr::left_join(edges, nodes, by = c('source' = 'label'))
  edges <- dplyr::select(edges, id = id.x, source = id.y, target, size = size.x) 
  edges <- dplyr::left_join(edges, nodes, by = c('target' = 'label')) 
  edges <- dplyr::select(edges, id = id.x, source, target = id.y, size = size.x)
  
  nodes$label <- as.character(nodes$label)
  edges$source <- as.character(edges$source)
  edges$target <- as.character(edges$target)
  
  if(length(grep('^#([[:alnum:]]){6}$', nodeColor)) == 0){
    nodeColor <- rgb(t(col2rgb(nodeColor)), maxColorValue = 255)
  }
  
  if(length(grep('^#([[:alnum:]]){6}$', edgeColor)) == 0){
    edgeColor <- rgb(t(col2rgb(edgeColor)), maxColorValue = 255)
  }
  
  options <- list(minNodeSize = minNodeSize, maxNodeSize = maxNodeSize, minEdgeSize = minEdgeSize, maxEdgeSize = maxEdgeSize, nodeColor = nodeColor, edgeColor = edgeColor)
  
  graph <- list(nodes, edges)
  names(graph) <- c('nodes','edges')
  
  out <- jsonlite::toJSON(graph, pretty = TRUE)
  
  x <- list(data = out, options = options)
  
  htmlwidgets::createWidget(name='sigmaNet', x, width = width, height = height, package = 'sigmaNet', elementId = elementId)
}