#' @title Plot detection matrix of a species
#'
#' @description A function to plot detection matrix for selected species.
#'
#' @param DetMatrix A detection matrix for selected species obtained from using swts::speciesDM() function.
#' @param label Whether to use label of the replicates (default = TRUE).
#' @param Title The title of the plot.
#'
#' @return A plot of species detection matrix.
#'
#'
#' @export
plotDM <- function(DetMatrix, label=TRUE, Title = "Title"){
  plotDM <- ggplot2::ggplot(DetMatrix, ggplot2::aes(x=X, y=Y, col=factor(Presence), label=Replicate))+
    ggplot2::geom_point()+ ggplot2::theme_bw() +
    ggplot2::labs(title = Title, x = "EAST", y = "NORTH",color = "Species") +
    ggplot2::scale_color_manual(labels = c("Undetected", "Detected"), values = c("blue", "red")) +
    ggplot2::guides(fill = ggplot2::guide_legend(ncol=2)) +
    ggplot2::theme(legend.position = "bottom", axis.text = ggplot2::element_blank(),
          legend.text = ggplot2::element_text(size=8),
          axis.ticks = ggplot2::element_blank(),
          axis.title= ggplot2::element_text(size = 8),
          plot.title = ggplot2::element_text(size = 10, face = "bold", color = "darkgreen"))
  if (label==TRUE){ plotDM <- plotDM + ggplot2::geom_label(size=2) }
  else{ plotDM <- plotDM }
  return(plotDM)
}
