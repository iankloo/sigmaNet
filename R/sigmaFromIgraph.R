#' Make a basic 'sigmaNet' graph object from an 'igraph' object
#'
#' Create a 'sigmaNet' object from an 'igraph' object.  The 'sigmaNet' object will be a basic visualization
#' of the 'igraph' object and is meant to be the starting point for the development of a useful 'Sigma.js'
#' visualization.  If you are familiar with the 'ggplot' syntax, this is similar to the basic 'ggplot'
#' function.
#'
#' @param graph An 'igraph' object
#' @param layout The output of one of the 'igraph' layout functions.  If not provided, layout_nicely() will be used (note, this will slow things down).
#' @param width Width of the resulting graph - defaults to fit container, probably leave this alone
#' @param height Height of the resulting graph - defaults to fit container, probably leave this alone
#' @param elementId Do not specify, this is used by the 'htmlwidgets' package
#'
#' @return A 'sigmaNet' object (which is an 'htmlwidget').  This object is meant to be called directly
#'   to render a default 'Sigma.js' visualization, or it can be passed to other arguments to
#'   change visualization attributes (colors, sizes, interactivity, etc.).
#'
#' @examples
#' library(igraph)
#' library(sigmaNet)
#'
#' data(lesMis)
#'
#' l <- layout_nicely(lesMis)
#' sig <- sigmaFromIgraph(graph = lesMis, layout = l)
#'
#' #render basic visualization by calling the object
#' sig
#' @import htmlwidgets
#' @export

sigmaFromIgraph <- function(graph, layout = NULL, width = NULL, height = NULL, elementId = NULL){
  graph_parse <- igraph::as_data_frame(graph, what = 'both')

  edges <- graph_parse$edges
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

  #weird behavior if try to get this from graph_parse object
  nodes <- graph_parse$vertices
  #nodes <- igraph::as_data_frame(graph, what = 'vertices')
  nodes$label <- row.names(nodes)
  nodes <- nodes[,'label', drop = FALSE]
  nodes <- cbind(nodes, l)
  colnames(nodes) <- c('label',"x", "y")
  nodes$id <- 1:nrow(nodes)
  nodes$size <- 1
  nodes$x <- as.numeric(nodes$x)
  nodes$y <- as.numeric(nodes$y)
  nodes$color <- '#3182bd'
  edges$color <- "#636363"

  edges$source <- nodes$id[match(edges$source, nodes$label)]
  edges$target <- nodes$id[match(edges$target, nodes$label)]

  nodes$label <- as.character(nodes$label)
  edges$source <- as.character(edges$source)
  edges$target <- as.character(edges$target)

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  options <- list(minNodeSize = 1, maxNodeSize = 3, minEdgeSize = 3, maxEdgeSize = 1,
                  neighborEvent = 'onClick', neighborStart = 'clickNode', neighborEnd = 'clickStage',
                  doubleClickZoom = TRUE, mouseWheelZoom = TRUE)

  out <- jsonlite::toJSON(graphOut, pretty = TRUE)
  x <- list(data = out, options = options, graph = graph_parse)

  htmlwidgets::createWidget(name='sigmaNet', x, width = width, height = height, package = 'sigmaNet', elementId = elementId)
}

