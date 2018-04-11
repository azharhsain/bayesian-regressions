## Some summary statistics
print(fit)

## Simple plot of the parameter distributions
plot(fit)

## Get the results as vectors and matrices
la <- extract(fit, permute=T)
names(la)

## Or as a data frame
df <- as.data.frame(fit)
head(df)

## As a regression table
tbl <- data.frame(name=c(), estimate=c(), stderr=c(), badge=c())
for (name in names(df)) {
    estimate <- mean(df[, name])
    stderr <- sd(df[, name])
    opposite.share <- sum(sign(estimate) != sign(df[, name])) / nrow(df)
    if (opposite.share < .001)
        badge <- "***"
    else if (opposite.share < .01)
        badge <- "**"
    else if (opposite.share < .05)
        badge <- "*"
    else if (opposite.share < .1)
        badge <- "."
    else
        badge <- ""
    
    tbl <- rbind(tbl, data.frame(name, estimate, stderr, badge))
}
print(tbl)

## Plot the distributions
library(ggplot2)
library(reshape2)

ggplot(melt(df), aes(value)) +
    facet_wrap(~ variable, scales="free") +
    geom_density() + theme_minimal() + xlab(NULL)
