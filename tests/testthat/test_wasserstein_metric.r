library("testthat")
library("waddR")

##########################################################################
##                    WASSERSTEIN METRIC CALCULATION                    ##
##########################################################################

# R implementation to test against, from the package transport
wasserstein1d <- function (a, b, p = 1, wa = NULL, wb = NULL) {
  m <- length(a)
  n <- length(b)
  stopifnot(m > 0 && n > 0)
  if (m == n && is.null(wa) && is.null(wb)) {
    return( mean( abs( sort(b) - sort(a) )^p )^(1/p))
  }
  if (is.null(wa)) {
    wa <- rep(1, m)
  }
  if (is.null(wb)) {
    wb <- rep(1, n)
  }
  stopifnot(length(wa) == m && length(wb) == n)
  
  # normalizes values to sum up to 1
  ua <- (wa/sum(wa))[-m]
  ub <- (wb/sum(wb))[-n]
  
  
  cua <- c(cumsum(ua))
  cub <- c(cumsum(ub))
  temp <- cut(cub, breaks = c(-Inf, cua, Inf))
  arep <- table(temp) + 1
  temp <- cut(cua, breaks = c(-Inf, cub, Inf))
  brep <- table(temp) + 1

  # repeat each element in a and b as often as the intervals in arep and brep
  # are mentionned
  aa <- rep(sort(a), times = arep)
  bb <- rep(sort(b), times = brep)
  
  # combine ecdf of weights vectors for a and b 
  uu <- sort(c(cua, cub))
  
  ## Quantiles of empirical Fa and Fb
  uu0 <- c(0, uu)
  uu1 <- c(uu, 1)
  areap <- sum((uu1 - uu0) * abs(bb - aa)^p)^(1/p)
  
  #cat("a length = ",length(a))
  #cat(" b length = ",length(b), "\n")
  #cat("ua length = ", length(ua))
  #cat(" ub length = ", length(ub), "\n")
  #cat("cua length = ", length(cua))
  #cat(" cub length = ", length(cub), "\n")
  #cat("arep length = ", length(arep))
  #cat(" brep length = ", length(brep), "\n")
  #cat("cua  = ", paste(as.character(cua), collapse=", "), "\n")
  #cat("cub  = ", paste(as.character(cua), collapse=", "), "\n")
  
  #cat("a_rep  = ", paste(as.character(arep), collapse=", "), "\n")
  #cat("b_rep  = ", paste(as.character(brep), collapse=", "), "\n")
  
  #cat("aa  = ", paste(as.character(aa), collapse=", "), "\n")
  #cat("bb  = ", paste(as.character(bb), collapse=", "), "\n")
  
  #cat("uu0  = ", paste(as.character(uu0), collapse=", "), "\n")
  #cat("uu1  = ", paste(as.character(uu1), collapse=", ")+, "\n")
  return(areap)
}


##################################################
#   WASSERSTEIN IMPLEMENTATION (Approximation)   #
##################################################

# test correctness of wasserstein approximation 
test_that("squared_wass_approx correctness", {
  
  a <- c(13, 21, 34, 23)
  b <- c(1,  1,  1,  2.3)
  # case with equally long vectors a and b
  expect_known("value", squared_wass_approx(a,b),
               file="known.values/testresult_squared_wass_approx_correctness1")
  set.seed(42)
  a2 <- rnorm(100, 10, 1)
  set.seed(24)
  b2 <- rnorm(102, 10.5, 1)
  expect_known("value", squared_wass_approx(a2,b2),
               file="known.values/testresult_squared_wass_approx_correctness3")
})


##################################################
#   WASSERSTEIN DECOMPOSITION (Approximation)    #
##################################################

# test correctnes of decomposed wasserstein approximation
test_that("squared_wass_decomp correctness", {
  a <- c(13, 21, 34, 23)
  b <- c(1,  1,  1,  2.3)
  # case with equally long vectors a and b
  expect_known("value", squared_wass_approx(a,b),
               file="known.values/testresult_squared_wass_decomp_correctness1")
})


##################################################
#       WASSERSTEIN_METRIC IMPLEMENTATION        #
##################################################

# test correctnes of wasserstein_metric versus an R implementation 
test_that("wasserstein_metric correctness", {
  #skip("wasserstein_metric will be deprecated, skipping all test for it")
  a <- c(13, 21, 34, 23)
  b <- c(1,  1,  1,  2.3)
  p <- 2
  # case with equally long vectors a and b
  expect_equal(wasserstein_metric(a,b,p), wasserstein1d(a,b,p))
  expect_equal(wasserstein_metric(a,b), wasserstein1d(a,b))
  
  # vectors of different lengths
  x <- c(34, 4343, 3090, 1309, 23.2)
  set.seed(42)
  a2 <- rnorm(100,10,1)
  set.seed(24)
  b2 <- rnorm(102,10.5, 1)
  expect_equal(wasserstein_metric(a2,b2,p), wasserstein1d(a2,b2,p))
  expect_equal(wasserstein_metric(a,x,p), wasserstein1d(a,x,p))
})

# test consistency of results
test_that("wasserstein_metric consistency test", {
  x <- c(2, 1, 3) 
  y <- c(3, 3, 2, 6)
  results <- sapply(1:10000, function(i) { wasserstein_metric(x, y, p=2)})
  first = results[1]
  expect_true(all(results == first))
} )

