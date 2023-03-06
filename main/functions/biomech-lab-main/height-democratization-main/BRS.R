## BEST SUBSET REGRESSION ##
# Select the best subset of features that satisfy a certain condition. For the aim 
# of the jump height democratization through smartphone-IMU measures, it was chosen 
# to use the lowest cross-validation error. That is, the best model was the one 
# minimizing the cross-validation error.
# ---------------------------------------------------------------------------------
# Author: Guido Mascia, MSc, PhD student at University of Rome "Foro Italico"
# Email: mascia.guido@gmail.com
# First Commit: 09.03.2022
# Last Modified: 09.03.2022
# ---------------------------------------------------------------------------------
## -- References -- ##
# [1] https://rdocumentation.org/packages/leaps/versions/3.1/topics/regsubsets
# [2] https://jslsoc.sitehost.iu.edu/files_research/testing_tests/hccm/00TAS.pdf
# ---------------------------------------------------------------------------------

# Loading required libraries
library(tidyverse)
library(caret)
library(leaps)
library(corrplot)
library(readr)
library(car)
library(tibble)
library(QuantPsyc)
library(jtools)
library(huxtable)
library(officer)
library(ggplot2)
library(broom.mixed)

## -- Initialize ad-hoc functions -- ##

# Model formula initialization
# It stores the regression formula so that it can be easily printed/retreived
get_model_formula <- function(id, object, outcome){
  # get models data
  models <- summary(object)$which[id,-1]
  # Get outcome variable
  #form <- as.formula(object$call[[2]])
  #outcome <- all.vars(form)[1]
  # Get model predictors
  predictors <- names(which(models == TRUE))
  predictors <- paste(predictors, collapse = "+")
  # Build model formula
  as.formula(paste0(outcome, "~", predictors))
}        

# Cross Validation error function
# Compute the CVerror for eahc fold
get_cv_error <- function(model.formula, data){
  set.seed(1)
  train.control <- trainControl(method = "cv", number = 10)
  cv <- train(model.formula, data = data, method = "lm",
              trControl = train.control)
  cv$results$RMSE
}

## -- MAIN CODE -- ##
# Load the dataset
# Notice that this is just an example, the dataset could not be shared, i.e.,
# you cannot find the "db.csv" file here. 
features <- read_csv("~/db.csv")

# Group the features. This line can be modified in order to exclude some variables
# from some further computation.
vars <- c("y","h","A","b","C","D","e","F","G","H","i","J","k","l","M","n","O","p",
         "q","r","s","t","u","W","f3","f2","f1", "Bi", "Tr", "Sc", "Ic")

# Create the database to be analyzed.
df <- features[vars]

# Run Best-Subsets Regression [1]
#   var~. : variable to be estimated (dependent)
#   data  : independent variables dataset
#   nvmax : maximum size of the subset to be examine
#   nbest : number of subset of each size to store
models <- regsubsets(y~., data = df, nvmax = length(vars), nbest = 1)
summary(models)

# Compute Cross-Validation errors
nmodels <- length(vars) - 1
model.ids <- 1 : nmodels
cv.errors <-  map(model.ids, get_model_formula, models, "y") %>%
  map(get_cv_error, data = df) %>%
  unlist()
round(cv.errors,3)

# Select the model that minimize the CV error
best_model_idx <- which.min(cv.errors)
round(coef(models, best_model_idx),3)
best.formula <- map(best_model_idx, get_model_formula, models, "y")

best_model <- lm(formula = best.formula[[1]], data = df)
summary(best_model)

# Standardized Beta Coefficients 
coef_lmbeta <- lm.beta(best_model)

## -- Store Report professionally -- ##
#   robust    : standard errors robustness [2]
#   scale     : scale coefficients
#   transform.response : get standardized beta coefficients
#   confint   : confidence intervals
#   digits    : number of digits
#   ci.width  : confidence interval width (.5 = 95%)
#   vifs      : compute Variance Inflation Factors
summ(best_model, robust = "HC3", scale = TRUE, n.sd = 2,  
     confint = TRUE, digits = 3, ci.width = .05, vifs = TRUE)

model_vif <- lm(y ~ h + A + b + D + e + O + t + f3 + f1 + Tr, data = df)
summ(model_vif, robust = "HC3", scale = TRUE, n.sd = 2,  
     confint = TRUE, digits = 3, ci.width = .95, vifs = TRUE)
betas <- lm.beta(model_vif)

## -- Check for possible Heteroskedasticity -- ##
# I am going to use the Non-Constant Variance Test test assuming:
#   · Null Hypothesis (H0): Homoscedasticity is present (the residuals are 
#      distributed with equal variance) <--> p >= 0.05
#   · Alternative Hypothesis (HA): Heteroscedasticity is present (the residuals 
#     are not distributed with equal variance) <--> p < 0.05
car::ncvTest(model_vif)

## -- Check if residuals are normally distributed -- ##
# I am going to use the Shapiro-Wilk test, where:
#   · Null Hypothesis (H0): Residuals are normally distributed <--> p >= 0.05
#   · Alternative Hypothesis (HA): Residuals are not normally distributed 
#   · <--> p < 0.05
# However, I have to "studentize" the residuals prior the S-W test
sresid <- MASS::studres(model_vif)
shapiro.test(sresid)

# Eventually store the data into a csv for further comparison
fitted_vals <- model_vif$fitted.values
vect <- matrix(ncol = 3, nrow = length(fitted_vals))
vect[,1] <- df$y
vect[,2] <- df$h
vect[,3] <- fitted_vals
write.csv(x = vect, file = "~/res.csv")