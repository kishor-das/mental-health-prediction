library(tidyverse)
library(tidymodels)
library(doParallel)
library(skimr)

# Update this path if your file is located elsewhere
data_path <- "./data/df_Ranked_Measure_Data_final.csv"


df <- readr::read_csv(data_path, guess_max = 10000)

# If column names contain spaces or special characters, make them syntactically valid
colnames(df) <- make.names(colnames(df))


# Quick peek
glimpse(df)


df_model <- 
  df %>%
  select(mentally.unhealthy.days,
        food.environment.index, 
         X..physically.inactive, X..some.college,
        population, X..unemployed, income.ratio, X..single.parent.households,
        X..violent.crimes) |>
  drop_na() |>
  slice(1:2000)

set.seed(2025)
split <- initial_split(df_model, prop = 0.75)
train_data <- training(split)
test_data <- testing(split)


nrow(train_data)
nrow(test_data)


rec <- recipe(mentally.unhealthy.days ~ ., data = train_data) |>
step_impute_median(all_numeric_predictors()) |>
step_nzv(all_numeric_predictors()) |>
step_normalize(all_numeric_predictors())


rec_prep <- prep(rec)
juice(rec_prep) %>% skimr::skim()


lin_spec <- linear_reg() %>%
set_engine("lm") %>%
set_mode("regression")


lin_wf <- workflow() %>%
add_model(lin_spec) %>%
add_recipe(rec)


lin_fit <- fit(lin_wf, data = train_data)


lin_fit



rf_spec <- rand_forest(mtry = tune(), trees = 1000, min_n = tune()) %>%
set_engine("ranger") %>%
set_mode("regression")


rf_wf <- workflow() %>%
add_model(rf_spec) %>%
add_recipe(rec)


# cross-validation folds
set.seed(2025)
folds <- vfold_cv(train_data, v = 5)


rf_grid <- grid_random(
mtry(range = c(4,5)),
min_n(range = c(35, 36)),
size = 20
)


rf_grid

# Parallel backend
cl <- makePSOCKcluster(parallel::detectCores()-1)
registerDoParallel(cl)


set.seed(2025)
rf_tune <- tune_grid(
rf_wf,
resamples = folds,
grid = rf_grid,
metrics = metric_set(rmse, rsq),
control = control_grid(save_pred = TRUE)
)


stopCluster(cl)


rf_tune %>% collect_metrics() %>% arrange(mean)


# Choose the best by rmse
best_rf <- select_best(rf_tune, metric ="rmse")
best_rf


# finalize the workflow with best params
rf_final_wf <- finalize_workflow(rf_wf, best_rf)


# Fit on the full training set
rf_final_fit <- fit(rf_final_wf, data = train_data)


rf_final_fit

# Collect performance for linear model via resamples
lin_res <- fit_resamples(
lin_wf,
resamples = folds,
metrics = metric_set(rmse, rsq),
control = control_resamples(save_pred = TRUE)
)


lin_metrics <- lin_res %>% collect_metrics()
rf_metrics <- rf_tune %>% collect_metrics() %>% filter(.metric == "rmse")


lin_metrics
rf_metrics %>% arrange(mean)


# Create a small comparison table (median RMSE across folds)
compare_tbl <- tibble(
model = c("Linear Regression", "Random Forest (tuned)"),
rmse = c(lin_metrics %>% filter(.metric=="rmse") %>% pull(mean),
rf_metrics %>% arrange(mean) %>% slice(1) %>% pull(mean))
)
compare_tbl




# For reproducibility, let's compute test RMSE for both models
# Linear model predictions
lin_pred <- predict(lin_fit, test_data) %>% bind_cols(test_data %>% select(mentally.unhealthy.days))
lin_test_rmse <- rmse(lin_pred, truth = mentally.unhealthy.days, estimate = .pred)




lin_test_rmse

saveRDS(lin_test_rmse, file = "./model/final_chosen_model.rds")
