# bayesian-regressions
Templates for Running Bayesian Regressions

## What are Bayesian Regressions?

First, they have nothing to do with learning, have no priors to be updated (usually), and will never show an explicit Bayes Rule.

The point of Bayesian Regressions is to allow non-parametric parameter
uncertainty.  The distribution of each parameter will be represented
by random draws from its distribution.

Some general insights:

 - The mode of the Bayesian parameters will be the MLE (or OLS)
   result.
   
 - The curvature of the parameter distributions at that peak equals
   the curvature of a normal distribution with the point estimate and
   standard error.
   
 - Computational Bayesian approaches make it very easy to choose
   different modeling assumptions (e.g., Cauchy errors and logistic
   regressions).
   
 - Bayesian regressions are useful for any dataset size, but can get
   prohibitively slow beyond 100k points.

## The templates

Each template (except the last one) has an example part and a general
part.  The example can be swapped out with the general part still
used.

 - Multivariate regression (`multivariate.R`)
 - Robust noise regression (`robustnoise.R`)
 - Fixed effects regression (`fixedeffects.R`)
 - Constrained parameter regression (`paramlimits.R`)

To start, install Stan using `setup.R`.  Then run the template of your choice, and display the results with the options in `display.R`.
