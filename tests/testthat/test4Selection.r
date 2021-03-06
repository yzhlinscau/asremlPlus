#devtools::test("asremlPlus")
context("model_selection")

cat("#### Test for chooseModel.asrtests with asreml4\n")
test_that("choose.model.asrtests_asreml4", {
  skip_if_not_installed("asreml")
  skip_on_cran()
  library(dae)
  library(asreml)
  library(asremlPlus)
  print(packageVersion("asreml"))
  data(WaterRunoff.dat)
  asreml.options(keep.order = TRUE)
  current.asr <- do.call("asreml",
                         args = list(fixed = log.Turbidity ~ Benches +
                                       (Sources * (Type + Species)) * Date,
                                     random = ~Benches:MainPlots:SubPlots:spl(xDay),
                                     data = quote(WaterRunoff.dat)))
  current.asrt <- as.asrtests(current.asr, NULL, NULL)
  terms.treat <- c("Sources", "Type", "Species", 
                   "Sources:Type", "Sources:Species")
  terms <- sapply(terms.treat, 
                  FUN=function(term){paste("Date:",term,sep="")}, 
                  simplify=TRUE)
  terms <- c("Date", terms)
  terms <- unname(terms)
  marginality <-  matrix(c(1,0,0,0,0,0, 1,1,0,0,0,0,  1,0,1,0,0,0, 
                           1,0,1,1,0,0, 1,1,1,0,1,0, 1,1,1,1,1,1), nrow=6)
  rownames(marginality) <- terms
  colnames(marginality) <- terms
  choose <- chooseModel(current.asrt, marginality, denDF="algebraic")
  current.asrt <- choose$asrtests.obj
  sig.terms <- choose$sig.terms
  testthat::expect_equal(length(sig.terms), 2)
  testthat::expect_equal(sig.terms[[1]], "Date:Species")
  testthat::expect_equal(sig.terms[[2]], "Date:Sources")
})

cat("#### Test for spline testing with asreml4\n")
test_that("spl.asrtests_asreml4", {
  skip_if_not_installed("asreml")
  skip_on_cran()
  library(dae)
  library(asreml)
  library(asremlPlus)
  print(packageVersion("asreml"))
  data(WaterRunoff.dat)
  asreml.options(keep.order = TRUE)
  current.asr <- do.call("asreml", 
                         args = list(fixed = log.Turbidity ~ Benches + 
                                       (Sources * (Type + Species)) * Date, 
                                     random = ~Benches:MainPlots:SubPlots:spl(xDay, k = 6), 
                                     data = WaterRunoff.dat))
  current.asrt <- as.asrtests(current.asr, NULL, NULL)
  
  #Test random splines
  current.asrt <- testranfix(current.asrt, term = "Benches:MainPlots:SubPlots:spl(xDay, k = 6)")
  current.asrt$test.summary
  
  testthat::expect_equal(nrow(current.asrt$test.summary), 1)
  testthat::expect_true(abs(current.asrt$test.summary$p - 0.08013755) < 1e-08)
  
  data(Wheat.dat)
  #'## Add cubic trend to Row so that spline is not bound
  Wheat.dat <- within(Wheat.dat, 
                      {
                        vRow <- as.numeric(Row)
                        vRow <- vRow - mean(unique(vRow))
                        yield <- yield + 10*vRow + 5 * (vRow^2) + 5 * (vRow^3)
                      })
  
  #'## Fit model using asreml4
  asreml.obj <- asreml(fixed = yield ~ Rep + vRow + Variety, 
                       random = ~spl(vRow, k=6) + units, 
                       residual = ~ar1(Row):ar1(Column), 
                       data = Wheat.dat, trace = FALSE)
  testthat::expect_false(abs(summary(asreml.obj)$varcomp$component[1] - 1.316595e-01) > 1e-06)
  testthat::expect_true(summary(asreml.obj)$varcomp$bound[1] == "B")
  asreml.obj <- asreml(fixed = yield ~ Rep + vRow + Variety, 
                       random = ~spl(vRow) + units, 
                       residual = ~ar1(Row):ar1(Column), 
                       data = Wheat.dat, trace = FALSE)
  testthat::expect_false(abs(summary(asreml.obj)$varcomp$component[1] - 4.902267e-02) > 1e-06)
  testthat::expect_true(summary(asreml.obj)$varcomp$bound[1] == "B")

})

cat("#### Test for reparamSigDevn.asrtests with asreml4\n")
test_that("reparamSigDevn.asrtests_asreml4", {
  skip_if_not_installed("asreml")
  skip_on_cran()
  library(dae)
  library(asreml)
  library(asremlPlus)
  data(WaterRunoff.dat)
  asreml.options(keep.order = TRUE)
  current.asr <- asreml(fixed = log.Turbidity ~ Benches + Sources + Type + Species + 
                          Sources:Type + Sources:Species + Sources:Species:xDay + 
                          Sources:Species:Date, 
                        data = WaterRunoff.dat)
  current.asrt <- as.asrtests(current.asr, NULL, NULL)
  
  #Examine terms that describe just the interactions of Date and the treatment factors
  terms.treat <- c("Sources", "Type", "Species", "Sources:Type", "Sources:Species")
  date.terms <- sapply(terms.treat, 
                       FUN=function(term){paste("Date:",term,sep="")}, 
                       simplify=TRUE)
  date.terms <- c("Date", date.terms)
  date.terms <- unname(date.terms)
  treat.marginality <-  matrix(c(1,0,0,0,0,0, 1,1,0,0,0,0,  1,0,1,0,0,0, 
                                 1,0,1,1,0,0, 1,1,1,0,1,0, 1,1,1,1,1,1), nrow=6)
  rownames(treat.marginality) <- date.terms
  colnames(treat.marginality) <- date.terms
  choose <- chooseModel(current.asrt, treat.marginality, denDF="algebraic")
  current.asrt <- choose$asrtests.obj
  current.asr <- current.asrt$asreml.obj
  sig.date.terms <- choose$sig.terms
  
  #Remove all Date terms left in the fixed model
  terms <- "(Date/(Sources * (Type + Species)))"
  current.asrt <- changeTerms(current.asrt, dropFixed = terms)
  #if there are significant date terms, reparameterize to xDays + spl(xDays) + Date
  if (length(sig.date.terms) != 0)
  { #add lin + spl + devn for each to fixed and random models
    trend.date.terms <- sapply(sig.date.terms, 
                               FUN=function(term){sub("Date","xDay",term)}, 
                               simplify=TRUE)
    trend.date.terms <- paste(trend.date.terms,  collapse=" + ")
    current.asrt <- changeTerms(current.asrt, addFixed=trend.date.terms)
    trend.date.terms <- sapply(sig.date.terms, 
                               FUN=function(term){sub("Date","spl(xDay)",term)}, 
                               simplify=TRUE)
    trend.date.terms <- c(trend.date.terms, sig.date.terms)
    trend.date.terms <- paste(trend.date.terms,  collapse=" + ")
    current.asrt <- changeTerms(current.asrt, addRandom = trend.date.terms)
    current.asrt <- rmboundary.asrtests(current.asrt)
  }
  
  #Now test terms for sig date terms
  spl.terms <- sapply(terms.treat, 
                      FUN=function(term){paste("spl(xDay):",term,sep="")}, 
                      simplify=TRUE)
  spl.terms <- c("spl(xDay)",spl.terms)
  lin.terms <- sapply(terms.treat, 
                      FUN=function(term){paste(term,":xDay",sep="")}, 
                      simplify=TRUE)
  lin.terms <- c("xDay",lin.terms)
  systematic.terms <- c(terms.treat, lin.terms, spl.terms, date.terms)
  systematic.terms <- unname(systematic.terms)
  treat.marginality <-  matrix(c(1,0,0,0,0,0, 1,1,0,0,0,0,  1,0,1,0,0,0, 
                                 1,0,1,1,0,0, 1,1,1,1,1,0, 1,1,1,1,1,1), nrow=6)
  systematic.marginality <- kronecker(matrix(c(1,0,0,0, 1,1,0,0, 
                                               1,1,1,0, 1,1,1,1), nrow=4), 
                                      treat.marginality)
  systematic.marginality <- systematic.marginality[-1, -1]
  rownames(systematic.marginality) <- systematic.terms
  colnames(systematic.marginality) <- systematic.terms
  choose <- chooseModel(current.asrt, systematic.marginality, 
                        denDF="algebraic", pos=TRUE)
  current.asrt <- choose$asrtests.obj
  
  #Check if any deviations are significant and, for those that are, go back to 
  #fixed dates
  current.asrt <- reparamSigDevn(current.asrt, choose$sig.terms, 
                                 trend.num = "xDay", devn.fac = "Date", 
                                 denDF = "algebraic")
  k <- match("Sources:Species:Date",rownames(current.asrt$wald.tab))
  testthat::expect_equal(nrow(current.asrt$wald.tab), 9)
  testthat::expect_equal(nrow(current.asrt$test.summary), 6)
  testthat::expect_true(!is.na(k))
})
