##### Example #####

## Show the data
require(graphics)
pairs(airquality[, 1:5], panel=panel.smooth, main="Air Quality data")

## Comparison
library(lfe)
summary(felm(Ozone ~ Solar.R + Wind + Temp | Month, data=airquality))

## Setup yy and XX inputs
yy <- airquality$Ozone
XX <- airquality[, c('Solar.R', 'Wind', 'Temp')]
groups <- airquality$Month

do.efficient <- F

##### Standard Structure #####

library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

## Code for a simple multivariate regression model
stan.code.simple <- "
data {
  int<lower=0> N; // number of observations
  int<lower=0> K; // number of predictors
  matrix[N, K] x; // predictor matrix
  vector[N] y;    // outcome vector

  int<lower=0> L; // number of FE classes
  int<lower=1, upper=L> groups[N]; // the groups themselves
}
parameters {
  vector[K] beta; // other coefficients
  vector[L] alphas; // fixed effects
  real<lower=0> sigma; // sd of errors
}
model {
  y ~ normal(x * beta + alphas[groups], sigma);
}"

## This needs to be used with demeaning
stan.code.faster <- "
data {
  int<lower=0> N; // number of observations
  int<lower=0> K; // number of predictors
  matrix[N, K] x; // predictor matrix
  vector[N] y;    // outcome vector
}
transformed data {
  matrix[N, K] Q_ast;
  matrix[K, K] R_ast;
  matrix[K, K] R_ast_inverse;
  // thin and scale the QR decomposition
  Q_ast = qr_Q(x)[, 1:K] * sqrt(N - 1);
  R_ast = qr_R(x)[1:K, ] / sqrt(N - 1);
  R_ast_inverse = inverse(R_ast);
}
parameters {
  real alpha;      // intercept
  vector[K] theta; // coefficients on Q_ast
  real<lower=0> sigma; // sd of errors
}
model {
  y ~ normal(Q_ast * theta + alpha, sigma);
}
generated quantities {
  vector[K] beta;
  beta = R_ast_inverse * theta; // coefficients on x
}"

## Drop observations with NAs
valid <- rowSums(is.na(XX)) + is.na(yy) + is.na(groups) == 0

## Prepare groups for FEs
valid.groups <- factor(groups[valid])

if (do.efficient) {
    allentries <- list(yy[valid])
    for (ii in 1:ncol(XX))
        allentries[[ii+1]] <- XX[valid, ii]

    demeaned <- demeanlist(allentries, list(valid.groups))

    dmyy <- demeaned[[1]]
    dmXX <- demeaned[[2]]
    for (ii in 2:ncol(XX))
        dmXX <- cbind(dmXX, demeaned[[ii+1]])

    stan.data <- list(N=sum(valid), K=ncol(XX), x=dmXX, y=dmyy)

    fit <- stan(model_code=stan.code.faster, data=stan.data)
} else {
    ## Setup data to send to Stan
    stan.data <- list(N=sum(valid), K=ncol(XX), x=XX[valid,], y=yy[valid], L=length(levels(valid.groups)), groups=as.numeric(valid.groups))

    ## Fit the model
    fit <- stan(model_code=stan.code.simple, data=stan.data)
}
