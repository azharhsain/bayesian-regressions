##### Example #####

## Show the data
require(graphics)
pairs(airquality[, 1:4], panel=panel.smooth, main="Air Quality data")

## Comparison
summary(lm(Ozone ~ Solar.R + Wind + Temp, data=airquality))

## Setup yy and XX inputs
yy <- airquality$Ozone
XX <- airquality[, c('Solar.R', 'Wind', 'Temp')]

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
}
parameters {
  real alpha;     // intercept
  vector[K] beta; // other coefficients
  real<lower=0> sigma; // sd of errors
}
model {
  y ~ normal(alpha + x * beta, sigma);
}"

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
valid <- rowSums(is.na(XX)) + is.na(yy) == 0

## Setup data to send to Stan
stan.data <- list(N=sum(valid), K=ncol(XX), x=XX[valid,], y=yy[valid])

## Fit the model
if (do.efficient) {
    fit <- stan(model_code=stan.code.faster, data=stan.data)
} else {
    fit <- stan(model_code=stan.code.simple, data=stan.data)
}
