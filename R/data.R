#' Co-appearances of characters in "Les Miserables"
#'
#' A graph where the nodes are characters in "Les Miserables" and the
#' edges are times that the characters appeared together in the novel.
#'
#' @format An igraph object with 77 nodes and 254 edges
#' \describe{
#'   \item{id}{numeric id of nodes}
#'   \item{label}{character label (names) of nodes}
#'   \item{value}{numeric weight of the edges (number of co-appearances)}
#' }
#' @source D. E. Knuth, The Stanford GraphBase: A Platform for Combinatorial Computing, Addison-Wesley, Reading, MA (1993)
"lesMis"
