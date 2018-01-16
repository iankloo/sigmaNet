#' Draw a network in sigmajs
#'
#' @param graph An igraph object
#' @param layout The output of one of the igraph layout functions.  If not provided, layout_nicely() will be used (note, this will slow things down).
#' @param nodeSizeMetric The metric to use when sizing the nodes.  Options are: degree, closeness, betweenness, pageRank, or eigenCentrality.
#' @param nodeLabel Which attribute to use as the node labels.  Default will be the "names" assigned by igraph - you probably don't need to change this.
#' @param edgeWeightAttr Which attribute to use as edge weights.  Defaults to NULL to render all edges the same size.
#' @param nodeColorPalette ??
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

sigmaNet <- function(graph, layout = NULL, nodeSizeMetric = 'degree', nodeLabels = NULL,
                     nodeColorAttr = NULL, edgeColorAttr = NULL, nodeColorPalette = 'Dark2', edgeColorPalette = 'Set2',
                     edgeWeightAttr = NULL, minNodeSize = 1, maxNodeSize = 8, minEdgeSize = 1,
                     maxEdgeSize = 1, nodeColor = "#3182bd", edgeColor =  "#636363", saveAs = NULL, showInViewer = TRUE,
                     width = NULL, height = NULL, elementId = NULL){

  if(!is.null(saveAs) & showInViewer == FALSE){
    stop('Please either save the result using the saveAs argument or set showInViewer to TRUE to see the result.')
  }

  edges <- igraph::as_data_frame(graph, what = 'edges')

  if(!is.null(edgeWeightAttr) & minEdgeSize == maxEdgeSize){
    message('To size edges based on your edgeWeight Attr, modify the min- and maxEdgeSize so they are not equal.')
  }

  if(is.null(edgeWeightAttr)){
    edges <- edges[, c('from', 'to')]
    edges$id <- 1:nrow(edges)
    edges$size <- 1
  } else{
    tryCatch({
      edges <- edges[,c('from', 'to', edgeWeightAttr)]
    }, error = function(e) {
      stop('Specified weight attribute does not exist in igraph object.')
    })
    edges$id <- 1:nrow(edges)
    edges$size <- edges$weight
    edges$weight <- NULL
  }
  edges$from <- as.character(edges$from)
  edges$to <- as.character(edges$to)
  colnames(edges) <- c('source','target', 'id','size')

  if(length(layout) == 0){
    l <- igraph::layout_nicely(graph)
  } else {
    l <- layout
  }

  nodes <- igraph::as_data_frame(graph, what = 'vertices')
  if(is.null(nodeLabels)){
    nodes$label <- row.names(nodes)
    nodes <- nodes[,'label', drop = FALSE]
  } else{
    tryCatch({
      nodes <- nodes[,nodeLabels, drop = FALSE]
      colnames(nodes) <- 'label'
    }, error = function(e) {
      stop('Specified node labels do not exist in igraph object.')
    })
  }

  nodes <- cbind(nodes, l)
  colnames(nodes) <- c('label',"x", "y")
  nodes$id <- 1:nrow(nodes)

  if(nodeSizeMetric == 'degree'){
    nodes$size <- igraph::degree(graph)
  } else if(nodeSizeMetric == 'closeness'){
    nodes$size <- igraph::closeness(graph)
  } else if(nodeSizeMetric == 'betweenness'){
    nodes$size <- igraph::betweenness(graph)
  } else if(nodeSizeMetric == 'pageRank'){
    nodes$size <- igraph::page_rank(graph)$vector
  } else if(nodeSizeMetric == 'eigenCentrality'){
    nodes$size <- igraph::eigen_centrality(graph)$vector
  } else{
    stop('NodeSizeMetric can only be one of: degree, closeness, betweenness, pageRank, or eigenCentrality.')
  }
  nodes$x <- as.numeric(nodes$x)
  nodes$y <- as.numeric(nodes$y)
  #need this to let people specify different attributes as labels
  nodes$oldLabs <- row.names(nodes)

  edges <- dplyr::left_join(edges, nodes, by = c('source' = 'oldLabs'))
  edges <- dplyr::select(edges, id = id.x, source = id.y, target, size = size.x)
  edges <- dplyr::left_join(edges, nodes, by = c('target' = 'oldLabs'))
  edges <- dplyr::select(edges, id = id.x, source, target = id.y, size = size.x)

  nodes$oldLabs <- NULL
  nodes$label <- as.character(nodes$label)
  edges$source <- as.character(edges$source)
  edges$target <- as.character(edges$target)

  if(!is.null(nodeColorAttr)){
    nodes$tempCol <- igraph::as_data_frame(graph, what = 'vertices')[,nodeColorAttr]
    suppressWarnings(pal <- brewer.pal(length(unique(nodes[,'tempCol'])), nodeColorPalette))
    palDF <- data.frame(group = unique(nodes[,'tempCol']), color = pal[1:length(unique(nodes[,'tempCol']))], stringsAsFactors = FALSE)
    nodes <- dplyr::left_join(nodes, palDF, by = c('tempCol' = 'group'))
    nodes$tempCol <- NULL
  }

  if(!is.null(edgeColorAttr)){
    edges$tempCol <- igraph::as_data_frame(graph, what = 'edges')[,edgeColorAttr]
    suppressWarnings(pal <- brewer.pal(length(unique(edges[,'tempCol'])), edgeColorPalette))
    palDF <- data.frame(group = unique(edges[,'tempCol']), color = pal[1:length(unique(edges[,'tempCol']))], stringsAsFactors = FALSE)
    edges <- dplyr::left_join(edges, palDF, by = c('tempCol' = 'group'))
    edges$tempCol <- NULL
  }

  if(length(grep('^#([[:alnum:]]){6}$', nodeColor)) == 0){
    nodeColor <- grDevices::rgb(t(grDevices::col2rgb(nodeColor)), maxColorValue = 255)
  }

  if(length(grep('^#([[:alnum:]]){6}$', edgeColor)) == 0){
    edgeColor <- grDevices::rgb(t(grDevices::col2rgb(edgeColor)), maxColorValue = 255)
  }

  options <- list(minNodeSize = minNodeSize, maxNodeSize = maxNodeSize, minEdgeSize = minEdgeSize, maxEdgeSize = maxEdgeSize, nodeColor = nodeColor, edgeColor = edgeColor)

  graphOut <- list(nodes, edges)
  names(graphOut) <- c('nodes','edges')

  out <- jsonlite::toJSON(graphOut, pretty = TRUE)

  x <- list(data = out, options = options)

  wid <- htmlwidgets::createWidget(name='sigmaNet', x, width = width, height = height, package = 'sigmaNet', elementId = elementId)

  if(!is.null(saveAs)){
    htmlwidgets::saveWidget(wid, file = saveAs)
  }
  if(showInViewer == TRUE){
    wid
  }
}

#' @export
sigmaNetOutput <- function(outputId, width = "100%", height = "400px") {
  shinyWidgetOutput(outputId, "sigmaNet", width, height, package = "sigmaNet")
}
#' @export
renderSigmaNet <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) }
  shinyRenderWidget(expr, sigmaNetOutput, env, quoted = TRUE)
}

# #add custom html for filter plugin
# sigmaNet_html <- function(id, style, class, ...){
#   htmltools::tags$div(
#     id = id, class = class, style = style,
#     htmltools::tags$div(
#       id = "control-pane",
#       htmltools::tags$h3('Filter by Degree'),
#       htmltools::tags$input(id = 'min-degree', type = 'range', min = '0', max = '0', value = '0')
#     )
#   )
# }

