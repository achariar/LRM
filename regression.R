# Load necessary libraries
library(ggplot2)
library(gridExtra)
library(dplyr)
library(car)
library(reshape2)

# Load the built-in economics dataset
data <- economics

# Data Inspection
summary(data)
str(data)

# Data Distribution
dist_pce <- ggplot(data, aes(x = pce)) +
  geom_histogram(bins = 30, fill = "blue", alpha = 0.7, color = "black") +
  labs(title = "Distribution of pce", x = "pce", y = "Frequency")

dist_pop <- ggplot(data, aes(x = pop)) +
  geom_histogram(bins = 30, fill = "green", alpha = 0.7, color = "black") +
  labs(title = "Distribution of pop", x = "pop", y = "Frequency")

dist_psavert <- ggplot(data, aes(x = psavert)) +
  geom_histogram(bins = 30, fill = "red", alpha = 0.7, color = "black") +
  labs(title = "Distribution of psavert", x = "psavert", y = "Frequency")

dist_unemploy <- ggplot(data, aes(x = unemploy)) +
  geom_histogram(bins = 30, fill = "purple", alpha = 0.7, color = "black") +
  labs(title = "Distribution of unemploy", x = "unemploy", y = "Frequency")

grid.arrange(dist_pce, dist_pop, dist_psavert, dist_unemploy, ncol = 2)

# Log Transformation
data <- data %>%
  mutate(
    log_pce = log(pce)
  )

# Data Distribution After Transformation
dist_log_pce <- ggplot(data, aes(x = log_pce)) +
  geom_histogram(bins = 30, fill = "blue", alpha = 0.7, color = "black") +
  labs(title = "Distribution of log_pce", x = "log_pce", y = "Frequency")

grid.arrange(dist_log_pce, dist_pop, dist_psavert, dist_unemploy, ncol = 2)

# Correlation Analysis
cor_matrix <- cor(data %>% select(log_pce, pop, psavert, unemploy), use = "complete.obs")
print(cor_matrix)

cor_melt <- melt(cor_matrix)
ggplot(cor_melt, aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1, 1)) +
  theme_minimal() +
  labs(title = "Correlation Matrix", x = "Variables", y = "Variables")

# Variance Inflation Factor (VIF) Analysis
model_vif <- lm(log_pce ~ pop + psavert + unemploy, data = data)
vif_values <- vif(model_vif)
vif_df <- data.frame(Variable = names(vif_values), VIF = vif_values)
print(vif_df)

# Regression Model (Excluding `pop`)
model <- lm(log_pce ~ psavert + unemploy, data = data)
summary(model)

# Residual Analysis
residuals <- resid(model)

plot1 <- ggplot(data, aes(x = fitted(model), y = residuals)) +
  geom_point() +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  labs(
    title = "Residuals vs Fitted Values",
    x = "Fitted Values",
    y = "Residuals"
  )

plot2 <- ggplot(data, aes(sample = residuals)) +
  stat_qq() +
  stat_qq_line() +
  labs(
    title = "Normal Q-Q Plot of Residuals"
  )

plot3 <- ggplot(data, aes(x = residuals)) +
  geom_histogram(bins = 30, fill = "blue", alpha = 0.7, color = "black") +
  labs(
    title = "Histogram of Residuals",
    x = "Residuals",
    y = "Frequency"
  )

print(plot1)
print(plot2)
print(plot3)

