##### Combined Example and Structure #####

## Load library
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

## Drop observations with NAs
valid <- !is.na(airquality$Ozone) & !is.na(airquality$Solar.R) & !is.na(airquality$Wind) & !is.na(airquality$Temp)

## Code for a simple multivariate regression model
stan.code <- "
data {
  int<lower=0> N; // number of observations
  vector[N] ozone;
  vector[N] solar;
  vector[N] wind;
  vector[N] temp;
}
parameters {
  real alpha;

  real<upper=0> beta_solar; // only allow negative
  real beta_wind;
  real<upper=0> beta_temp; // only allow negative

  real<lower=0> sigma;
}
model {
  beta_wind ~ normal(0, 1); // prior on wind

  ozone ~ normal(alpha + beta_solar * solar + beta_wind * wind + beta_temp * temp, sigma);
}"

## Setup data to send to Stan
stan.data <- list(N=sum(valid), ozone=airquality$Ozone[valid], solar=airquality$Solar.R[valid], wind=airquality$Wind[valid], temp=airquality$Temp[valid])

## Fit the model
fit <- stan(model_code=stan.code, data=stan.data)

## Get data as data.frame
df <- as.data.frame(fit)

library(ggplot2)
library(reshape2)

ggplot(melt(df), aes(value)) +
    facet_wrap(~ variable, scales="free") +
    geom_density() + theme_minimal() + xlab(NULL)
