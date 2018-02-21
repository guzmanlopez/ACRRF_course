###
### PRACTICO 1
###

# 1. Data -----------------------------------------------------------------

# 1. Load library
library(kernlab)

# 2. Load dataset
data(spam)

# Explore dataset

?spam
str(spam) # data.frame':	4601 obs. of  58 variables:

head(spam)

# Build dataframes with stratified sampling
library(dplyr)

# Add id column
spam$ID <- 1:nrow(spam)

set.seed(1)

sample.learn.strat <- 
  spam %>%
  group_by(type) %>%
  sample_frac(0.70)

sample.test.strat <- spam[-sample.learn.strat$ID,]

# Remove ID column
sample.learn.strat <- sample.learn.strat[,-59]
sample.test.strat <- sample.test.strat[,-59]

# Build dataframes with random sampling
# sample.learn <- sample(1:nrow(spam), size = round(nrow(spam) * 0.70))
# learn <- spam[sample.learn,] # 70% of the data
# test <- spam[-sample.learn,] # 30% of the data

# 2. CART trees -----------------------------------------------------------

# 1. Load library
library(rpart)

# 2. Default tree
tree.def <- rpart(type ~ ., data = sample.learn.strat)

plot(tree.def)
text(tree.def, cex = 0.8, use.n = TRUE, xpd = TRUE, col = "darkred")

# 3. Build a tree of depth 1 (stump) and draw it

tree.depth1 <- rpart(type ~ ., data = sample.learn.strat, maxdepth = 1)

plot(tree.depth1)
text(tree.depth1, cex = 0.8, use.n = TRUE, xpd = TRUE, col = "darkred")

# 4. Examine splits: primary splits and surrogate splits

summary(tree.depth1)
tree.depth1$splits

# 5. Build a maximal tree and draw it

tree.max <- rpart(type ~ ., data = sample.learn.strat, cp = 0)

plot(tree.max)
text(tree.max, cex = 0.8, use.n = TRUE, xpd = TRUE, col = "darkred")

# 6. Draw the OOB errors of the Breiman’s sequence of the pruned subtrees of the maximal tree and interpret it

printcp(tree.max)
plotcp(tree.max)

# 7. Find the best of them in the sense of an estimate given by the cross-validation prediction error

# https://stackoverflow.com/questions/29197213/what-is-the-difference-between-rel-error-and-x-error-in-a-rpart-decision-tree#29197763
# The x-error is the cross-validation error (rpart has built-in cross validation)

# rel_error + xstd < xerror
# tree.best <- tree.max$cptable[which.min(tree.max$cptable[, "rel error"] + tree.max$cptable[, "xstd"]),]

tree.best <- tree.max$cptable[which.min(tree.max$cptable[, "xerror"]),]
tree.best.cp <- tree.max$cptable[which.min(tree.max$cptable[, "xerror"]), "CP"]

tree.pruned <- prune(tree.max, cp = tree.best.cp)

# 8. Compare the default tree of rpart with the one obtained by minimizing the prediction error. Same question with the one obtained by applying the 1 SE rule

# xerror < min(xerror) + xstd
tree.max$cptable[, "xerror"] < min(tree.max$cptable[, "xerror"]) + tree.max$cptable[, "xstd"]
  
tree.best.1se <- tree.max$cptable[12, "CP"]
tree.pruned.1se <- prune(tree.max, cp = tree.best.1se)

par(mfrow = c(1, 3))

plot(tree.def, main = "Default")
text(tree.def, cex = 0.8, use.n = TRUE, xpd = TRUE, col = "darkred")

plot(tree.pruned, main = "Minimizing pred. error")
text(tree.pruned, cex = 0.8, use.n = TRUE, xpd = TRUE, col = "darkgreen")

plot(tree.pruned.1se, main = "1 se")
text(tree.pruned.1se, cex = 0.8, use.n = TRUE, xpd = TRUE, col = "darkblue")

par(mfrow = c(1, 1))

plotcp(tree.max)


# 9. Compare the errors of the different trees obtained, both in learning and in test

tree.max.test <- rpart(type ~ ., data = sample.test.strat, cp = 0)
