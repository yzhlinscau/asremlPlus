\name{allDifferences.data.frame}
\alias{allDifferences.data.frame}
\alias{allDifferences}
\title{Using supplied predictions and standard errors of pairwise differences or the 
       variance matrix of predictions, forms all pairwise differences between the 
       set of predictions, and p-values for the differences.}
\description{Uses supplied predictions and standard errors of pairwise differences, 
       or the variance matrix of predictions to form, in an 
       \code{\link{alldiffs.object}}, for those components not already present, 
       (i) a table of all pairwise differences of the predictions, 
       (ii) the p-value of each pairwise difference, and 
       (iii) the minimum, mean and  maximum LSD values. 
       Predictions that are aliased (or nonestimable) are removed from the 
       \code{predictions} component of the \code{\link{alldiffs.object}} and 
       standard errors of differences involving them are removed from the \code{sed} 
       component. 

       If necessary, the order of the columns of the variables in the \code{predictions} 
       component are changed to be the initial columns of the \code{\link{predictions.frame}} 
       and to match their order in the \code{classify}.  Also, the rows of \code{predictions} 
       component are ordered so that they are in standard order for the variables in the 
       \code{classify}. That is, the values of the last variable change with every row, 
       those of the second-last variable only change after all the values of the last 
       variable have been traversed; in general, the values of a variable are the same for 
       all the combinations of the values to the variables to its right in the 
       \code{classify}. The \code{sortFactor} or \code{sortOrder} arguments can be used 
       to order of the values for the \code{classify} variables, which is achieved using 
       \code{\link{sort.alldiffs}}. 

       Each p-value is computed as the probability of a t-statistic as large as or larger 
       than the absolute value of the observed difference divided by its standard error. The 
       p-values are stored in the \code{p.differences} component. The degrees of freedom of 
       the t-distribution is the degrees of freedom stored in the \code{tdf} attribute of 
       the \code{\link{alldiffs.object}}. This t-distibrution is also used in calculating 
       the LSD statistics stored in the \code{\link{alldiffs.object}}.
}
\usage{
\method{allDifferences}{data.frame}(predictions, classify, vcov = NULL, 
               differences = NULL, p.differences = NULL, sed = NULL, 
               LSD = NULL, meanLSD.type = "overall", LSDby = NULL, 
               backtransforms = NULL, 
               response = NULL, response.title = NULL, 
               term = NULL, tdf = NULL,  
               x.num = NULL, x.fac = NULL,  
               level.length = NA, 
               pairwise = TRUE, alpha = 0.05,
               transform.power = 1, offset = 0, scale = 1, 
               inestimable.rm = TRUE,
               sortFactor = NULL, sortWithinVals = NULL, 
               sortOrder = NULL, decreasing = FALSE, ...)}
\arguments{
 \item{predictions}{A \code{\link{predictions.frame}}, or a \code{data.frame}, beginning 
                    with the variables classifying the predictions and also containing columns 
                    named \code{predicted.value}, \code{standard.error} and \code{est.status}; 
                    each row contains a single predicted value. It may also contain columns 
                    for the lower and upper limits of error intervals for the predictions.
                    Note that the names \code{standard.error} and 
                    \code{est.status} have been changed to \code{std.error} and \code{status} 
                    in the \code{pvals} component produced by \code{asreml-R4}; if the new names 
                    are in the \code{data.frame} supplied to \code{predictions}, they will be 
                    returned to the previous names. }
 \item{classify}{A \code{character} string giving the variables that define the margins 
                    of the multiway table that has been predicted. Multiway tables are 
                    specified by forming an interaction type term from the 
                    classifying variables, that is, separating the variable names 
                    with the \code{:} operator.}
\item{vcov}{A \code{matrix} containing the variance matrix of the predictions; it is used in 
                    computing the variance of linear transformations of the predictions.}
\item{differences}{A \code{matrix} containing all pairwise differences between
                    the predictions; it should have the same number of rows and columns as there are
                    rows in \code{predictions}.}
 \item{p.differences}{A \code{matrix} containing p-values for all pairwise differences 
                    between the predictions; each p-value is computed as the probability of a t-statistic 
                    as large as or larger than the observed difference divided by its standard error. 
                    The degrees of freedom of the t distribution for computing it are computed as 
                    the denominator degrees of freedom of the F value for the fixed term, if available; 
                    otherwise, the degrees of freedom stored in the attribute \code{tdf} are used; 
                    the matrix should be of the same size as that for \code{differences}.}
 \item{sed}{A \code{matrix} containing the standard errors of all pairwise differences 
                    between the predictions; they are used in computing the p-values.}
\item{LSD}{A \code{data.frame} containing the mean, minimum and maximum LSD for determining             
                    the significance of pairwise differences, the mean LSD being calculated using 
                    the square root of the mean of the variances of pairwise differences. 
                    If \code{factor.combination} was specified for \code{meanLSD.type} when the 
                    LSDs were being calculated, then \code{LSD} contains an LSD for each 
                    \code{factor.combination} of the \code{\link{factor}s} specified by \code{LSDby}; 
                    each LSD is the square root of the mean of the variances for all 
                    pairwise differences for each factor combination. 
                    If \code{LSD} is not \code{NULL} then the overall mean LSD will be added as 
                    an attribute named \code{meanLSD} of the \code{\link{alldiffs.object}}, as will 
                    the values of \code{meanLSD.type} and \code{LSDby}.}
 \item{meanLSD.type}{A \code{\link{character}} string determining whether the mean LSD stored is 
             (i) the \code{overall} mean, based on the square root of the mean of the variances of 
             all pairwise variances, (ii) the mean for each \code{factor.combination} of the 
             \code{\link{factor}s} specified by \code{LSDby}, which is based on the square root of 
             the mean of the variances for all pairwise differences for each factor combination, or 
             (iii) the \code{per.prediction} mean, based, for each prediction, 
             on the square root of the mean of the variances for all pairwise differences involving 
             that prediction. If \code{LSD} is not \code{NULL} then \code{meanLSD.type} will be added 
             as an attribute of the \code{\link{alldiffs.object}}.}
\item{LSDby}{A \code{\link{character}} (vector) of variables names, being the names of the 
             \code{\link{factor}s} or \code{\link{numeric}s} in the \code{classify} for each 
             combination of which a mean LSD, minLSD and max LSD is stored in the \code{LSD} 
             component of the \code{\link{alldiffs.object}} when \code{meanLSD.type} is 
             \code{factor.combinatons}.}
 \item{backtransforms}{A \code{data.frame} containing the backtransformed values of the predicted 
                    values  that is consistent with the \code{predictions} component, except 
                    that the column named \code{predicted.value} is replaced by one called 
                    \code{backtransformed.predictions}. Any \code{error.interval} values will also 
                    be the backtransformed values. Each row contains a single predicted value.}
 \item{response}{A \code{character} specifying the response variable for the 
                    predictions. It is stored as an attribute to the \code{\link{alldiffs.object}}.}
 \item{response.title}{A \code{character} specifying the title for the response variable 
                    for the predictions. It is stored as an attribute to the \code{\link{alldiffs.object}}.}
 \item{term}{A character string giving the variables that define the term 
                 that was fitted using \code{asreml} and that corresponds 
                 to \code{classify}. It is often the same as \code{classify}. 
                 It is stored as an attribute to the \code{\link{alldiffs.object}}.}
 \item{tdf}{an \code{integer} specifying the degrees of freedom of the standard error. It is used as 
                the degrees of freedom for the t-distribution on which p-values and confidence 
                intervals are based. 
                It is stored as an attribute to the \code{\link{alldiffs.object}}.}
 \item{x.num}{A character string giving the name of the numeric covariate that 
              corresponds to \code{x.fac}, is potentially included in terms in the 
              fitted model and which corresponds to the x-axis variable. It should 
              have the same number of unique values as the number of levels in 
              \code{x.fac}.}
 \item{x.fac}{A character string giving the name of the factor that corresponds to 
              \code{x.num}, is potentially included in terms in the fitted model and 
              which corresponds to the x-axis variable. It should have the same 
              number of levels as the number of unique values in \code{x.num}. 
              The levels of \code{x.fac} must be in the order in which they are to 
              be plotted - if they are dates, then they should be in the form 
              yyyymmdd, which can be achieved using \code{as.Date}. However, the levels
              can be non-numeric in nature, provided that \code{x.num} is also set.}
 \item{level.length}{The maximum number of characters from the the levels of 
            factors to use in the row and column labels of the tables of 
            pairwise differences and their p-values and standard errors.}
 \item{pairwise}{A logical indicating whether all pairwise differences of the
                \code{predictions} and their standard errors and p-values are to be 
                computed and stored. If \code{FALSE}, the components \code{differences} 
                and \code{p.differences} will be \code{NULL} in the returned 
                \code{\link{alldiffs.object}}.}
 \item{alpha}{The significance level for an LSD to compare a pair of predictions.}
 \item{transform.power}{A \code{\link{numeric}} specifying the power of a transformation, if 
              one has been applied to the response variable. Unless it is equal 
              to 1, the default, back-transforms of the predictions will be 
              obtained and presented in tables or graphs as appropriate. 
              The back-transformation raises the predictions to the power equal 
              to the reciprocal of \code{transform.power}, unless it equals 0 in 
              which case the exponential of the predictions is taken.} 
 \item{offset}{A \code{\link{numeric}} that has been added to each value of the 
               response after any scaling and before applying any power transformation.}
 \item{scale}{A \code{\link{numeric}} by which each value of the response has been multiplied 
               before adding any offset and applying any power transformation.}
 \item{inestimable.rm}{A \code{logical} indicating whether rows for  predictions that 
                       are not estimable are to be removed from the components of the
                       \code{\link{alldiffs.object}}.}
\item{sortFactor}{A \code{character} containing the name of the 
              \code{factor} that indexes the set of predicted values that determines 
              the sorting of each component of the the \code{\link{alldiffs.object}} by 
              \code{\link{sort.alldiffs}}. If \code{NULL} then sorting is not carried 
              out. If there is more than one variable 
              in the \code{classify} term then \code{sortFactor} is sorted for the 
              predicted values within each combination of the values of the sortWithin 
              variables: the \code{classify} variables, excluding the 
              \code{sortFactor}. There should be only one predicted value for 
              each unique value of \code{sortFactor} within each set defined by a 
              combination of the values of the sortWithin variables.}
 \item{sortWithinVals}{A \code{list} with a component named for each \code{factor} and 
              \code{numeric} that is a \code{classify} variable for the predictions, 
              excluding \code{sortFactor}. Each component should contain a single 
              value that is a value of the variable. The combination of this set 
              of values will be used to define a subset of the predicted values whose 
              order will define the order of \code{sortFactor} to be used for all 
              combinations of the \code{sortWithinVals} variables. If 
              \code{sortWithinVals} is \code{NULL} then the first value of each 
              sortWithin variable in \code{predictions} component is used 
              to define \code{sortWithinVals}. If there is only one variable in the 
              classify then \code{sortWithinVals} is ignored.}
 \item{sortOrder}{A \code{character vector} whose length is the same as the number 
               of levels for \code{sortFactor} in the \code{predictions} component of the 
              \code{\link{alldiffs.object}}. It specifies the desired order of the 
              levels in the reordered components of the \code{\link{alldiffs.object}}. 
              The argument \code{sortWithinVals} is ignored.

              The following creates a \code{sortOrder} vector \code{levs} for factor 
              \code{f} based on the values in \code{x}:  \cr
              \code{levs <- levels(f)[order(x)]}.}
 \item{decreasing}{A \code{logical} passed to \code{order} that detemines whether 
              the order for sorting the components of the \code{\link{alldiffs.object}} 
              is for increasing or decreasing magnitude of the predicted values.}
 \item{\dots}{provision for passsing arguments to functions called internally - 
            not used at present.}
}
\value{An \code{\link{alldiffs.object}} with components 
       \code{predictions}, \code{vcov}, \code{differences}, \code{p.differences} 
       \code{sed}, and \code{LSD}. 

       The name of the \code{response}, the \code{response.title}, 
       the \code{term}, the \code{classify}, \code{tdf}, \code{sortFactor} 
       and the \code{sortOrder} will be set as attributes to the object. 
       Note that the \code{classify} in an \code{\link{alldiffs.object}} is based on the 
       variables indexing the predictions, which may differ from the 
       \code{classify} used to obtain the original predictions (for example, 
       when the \code{\link{alldiffs.object}}s stores a linear transformation of predictions.

       Also, see \code{\link{predictPlus.asreml}} for more information.
}


\author{Chris Brien}
\seealso{\code{\link{asremlPlus-package}}, \code{\link{as.alldiffs}},  \code{\link{as.predictions.frame}}, 
         \code{\link{sort.alldiffs}}, \code{\link{subset.alldiffs}},  \cr 
         \code{\link{print.alldiffs}},  \code{\link{renewClassify.alldiffs}},  
         \code{\link{redoErrorIntervals.alldiffs}},  \cr
         \code{\link{recalcLSD.alldiffs}},  \code{\link{plotPredictions.data.frame}}, 
         \code{\link{predictPlus.asreml}}, \cr 
         \code{\link{predictPresent.asreml}}}
\examples{
  data(Oats.dat)
  
  ## Use asreml to get predictions and associated statistics

  \dontrun{
  m1.asr <- asreml(Yield ~ Nitrogen*Variety, 
                   random=~Blocks/Wplots,
                   data=Oats.dat)
  current.asrt <- as.asrtests(m1.asr)
  Var.pred <- asreml::predict.asreml(m1.asr, classify="Nitrogen:Variety", 
                                      sed=TRUE)
  if (getASRemlVersionLoaded(nchar = 1) == "3")
    Var.pred <- Var.pred$predictions
  Var.preds <- Var.pred$pvals
  Var.sed <- Var.pred$sed
  Var.vcov <- NULL
  wald.tab <-  current.asrt$wald.tab
  den.df <- wald.tab[match("Variety", rownames(wald.tab)), "denDF"]
  }

  ## Use lmerTest and emmmeans to get predictions and associated statistics
  if (requireNamespace("lmerTest", quietly = TRUE) & 
      requireNamespace("emmeans", quietly = TRUE))
  {
    m1.lmer <- lmerTest::lmer(Yield ~ Nitrogen*Variety + (1|Blocks/Wplots),
                              data=Oats.dat)
    Var.emm <- emmeans::emmeans(m1.lmer, specs = ~ Nitrogen:Variety)
    Var.preds <- summary(Var.emm)
    den.df <- min(Var.preds$df)
    ## Modify Var.preds to be compatible with a predictions.frame
    Var.preds <- as.predictions.frame(Var.preds, predictions = "emmean", 
                                      se = "SE", interval.type = "CI", 
                                      interval.names = c("lower.CL", "upper.CL"))
    Var.vcov <- vcov(Var.emm)
    Var.sed <- NULL
  }

  ## Use the predictions obtained with either asreml or lmerTest
  if (exists("Var.preds"))
  {
    ## Order the Varieties in decreasing order for the predictions values in the 
    ## first N level 
    Var.diffs <- allDifferences(predictions = Var.preds, 
                                classify = "Nitrogen:Variety", 
                                sed = Var.sed, vcov = Var.vcov, tdf = den.df,
                                sortFactor = "Variety", decreasing = TRUE)
    print.alldiffs(Var.diffs, which="differences")
  
    ## Change the order of the factors in the alldiffs object and reorder components
    Var.reord.diffs <- allDifferences(predictions = Var.preds,
                                classify = "Variety:Nitrogen", 
                                sed = Var.sed, vcov = Var.vcov, tdf = den.df)
    print.alldiffs(Var.reord.diffs, which="predictions")
  }
}
\keyword{asreml}