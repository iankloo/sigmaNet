#' Create a UI element for a 'sigmaNet' visualization in 'Shiny'
#'
#' @param outputId The ID of the UI element
#' @param width The width of the UI element
#' @param height The height of the UI element
#'
#' @import htmlwidgets
#' @export
sigmaNetOutput <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(outputId, "sigmaNet", width, height, package = "sigmaNet")
}
#' Render a 'sigmaNet' visualization in 'Shiny'
#'
#' @param expr An expression that creates a 'sigmaNet' visualization
#' @param env Defaults to parent.frame() - see 'Shiny' docs for more info
#' @param quoted Defaults to FALSE - see 'Shiny docs for more info
#'
#' @import htmlwidgets
#' @export
renderSigmaNet <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) }
  htmlwidgets::shinyRenderWidget(expr, sigmaNetOutput, env, quoted = TRUE)
}
