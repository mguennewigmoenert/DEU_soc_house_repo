
# Load required libraries
library(ggplot2)
library(dplyr)
library(haven)
library(stringr)

# set path to folder
inputpath = "/Users/maxmonert/Library/CloudStorage/Dropbox/Projects/DEU Housing Project/"
outputpath = '/Users/maxmonert/Desktop/Research/Projects/SocialHousing/presentations/24.11.08/assets/'

# path to data
source = str_c(inputpath, "data/")

# upload main dataframe
socialhousing_analysis = data.frame(read_dta(str_c(source, "temp/socialhousing_analysis.dta")))

x =  socialhousing_analysis[c("jahr", "PLR_ID_num", "treat1")]

# set to numeric
socialhousing_analysis = 
socialhousing_analysis |>
  mutate(sum_dd_socialh = as.numeric(sum_dd_socialh),
         PLR_ID_num = as.numeric(PLR_ID_num),
         jahr = as.numeric(jahr),
         treat1 = as.numeric(treat1)
        )
                
DisplayTreatment(
  unit.id = "PLR_ID_num",
  time.id = "jahr",
  legend.position = "none",
  xlab = "Year",
  ylab = "PLR",
  treatment = "treat1",
  
  hide.x.tick.label = F, hide.y.tick.label = TRUE, 
  # dense.plot = TRUE,
  data = socialhousing_analysis |> filter(a100_r==1)
)

# readymade code
DisplayTreatment(
  unit.id = "PLR_ID_num",
  time.id = "jahr",
  legend.position = "none",
  xlab = "Year",
  ylab = "PLR",
  treatment = "treat1",
  legend.labels = c("not treated", "treated"),
  hide.x.tick.label = TRUE, hide.y.tick.label = TRUE, 
  # dense.plot = TRUE,
  data = socialhousing_analysis |> filter(!is.na(PLR_ID_num) & a100_r==0)
  )

# own plot, including both
socialhousing_analysis |>
  # Reorder PLR_ID_num based on a100_r and sum_dd_socialh
  arrange(
    desc(a100_r),                      # a100_r == 1 first, then a100_r == 0
    sum_dd_socialh == 0,               # Rows where sum_dd_socialh == 0 come first within each group
    sum_dd_socialh                     # Ascending order of sum_dd_socialh
  ) |>
  mutate(
    PLR_ID_num = factor(PLR_ID_num, levels = unique(PLR_ID_num)),  # Update PLR_ID_num to reflect the new order
    fill_color = case_when(
      a100_r == 1 & treat1 == 0 ~ "Within A100 Untreated",
      a100_r == 1 & treat1 == 1 ~ "Within A100 Treated",
      a100_r == 0 & treat1 == 0 ~ "Outside A100 Untreated",
      a100_r == 0 & treat1 == 1 ~ "Outside A100 Treated"
    ),
    alpha_category = case_when(
      a100_r == 1 & treat1 == 0 ~ "Within A100 Untreated",
      a100_r == 1 & treat1 == 1 ~ "Within A100 Treated",
      a100_r == 0 & treat1 == 0 ~ "Outside A100 Untreated",
      a100_r == 0 & treat1 == 1 ~ "Outside A100 Treated"
    )
  ) |>
  # Create the plot
  ggplot(aes(x = jahr, y = PLR_ID_num, fill = fill_color, alpha = alpha_category)) +
  geom_tile(color = "white", height = 1) +
  scale_fill_manual(
    values = c(
      "Within A100 Untreated" = "blue",
      "Within A100 Treated" = "red",
      "Outside A100 Untreated" = "blue",
      "Outside A100 Treated" = "red"
    ),
    name = "Treatment"
  ) + 
  scale_alpha_manual(
    values = c(
      "Within A100 Untreated" = 1,
      "Within A100 Treated" = 1,
      "Outside A100 Untreated" = 0.6,
      "Outside A100 Treated" = 0.6
    ),
    name = "Treatment"
  ) +
  labs(
    title = "Treatment Distribution Across Units and Time",
    x = "Year",
    y = "PLR"
  ) +
  scale_x_continuous(
    breaks = seq(min(socialhousing_analysis$jahr), max(socialhousing_analysis$jahr), by = 1),
    labels = seq(min(socialhousing_analysis$jahr), max(socialhousing_analysis$jahr), by = 1)
  ) +
  theme(
    axis.text.y = element_blank(),  # Remove y-axis ticks
    axis.title.x = element_text(size = 12, face = "bold"),  # Remove y-axis title
    axis.ticks.y = element_blank(),  # Remove y-axis tick marks
    axis.title.y = element_text(size = 12, face = "bold"),  # Remove y-axis title
    axis.text.x = element_text(size = 10, hjust = .5) # Shift x-axis labels slightly to the right
  )

# replication of set-up for ready made code
unit.id = "PLR_ID_num"
time.id = "jahr"
treatment = "treat1"
a100_r = "a100_r"
decreasing = F
xlab = "Year"
ylab = "PLR"
title = "Treatment Distribution \n Across Units and Time"
legend.labels = c("not treated", "treated")
color.of.treated = "red"
color.of.untreated = "blue"
x.size = NULL
y.size = NULL
legend.position = "none"
x.angle = NULL
y.angle = NULL
legend.labels = c("not treated", "treated")

data = socialhousing_analysis

data <- data[order(data[, unit.id], data[, time.id]), ]
data <- na.omit(data[c(unit.id, time.id, treatment, a100_r)])
colnames(data) <- c("unit.id", "time.id", "treatment", "a100_r")
data$trintens <- as.numeric(tapply(data$treatment, data$unit.id, 
                                   mean, na.rm = TRUE)[as.character(data$unit.id)])
data <- data[order(data$trintens, decreasing = decreasing), 
]
data$unit.id <- factor(data$unit.id, levels = unique(as.character(data$unit.id)))
data$time.id <- factor(x = data$time.id, levels = sort(unique(data$time.id)), 
                       ordered = TRUE)
data |>
  filter(a100_r == 1) |>
ggplot(aes(y = unit.id, x = time.id)) + 
  geom_tile(aes(fill = treatment), colour = "white") +
  scale_fill_gradient(low = color.of.untreated, 
                        high = color.of.treated, guide = "legend", breaks = c(0, 1), 
                        labels = legend.labels) + 
                        theme_bw() + 
                        labs(title = title, 
                        x = xlab, y = ylab, fill = "") + 
  theme(axis.ticks.x = element_blank(), 
        panel.grid.major = element_blank(), 
        panel.border = element_blank(), 
        legend.position = legend.position, 
        panel.background = element_blank(), 
        axis.text.x = element_text(angle = x.angle, size = x.size, 
                        vjust = 0.5), 
        axis.ticks.y = element_blank(), 
        axis.text.y = element_blank(),   # Remove y-axis labels
        plot.title = element_text(hjust = 0.5))

ggsave(str_c(outputpath, "graphs/treatment_distribution_a100_1.png"), width = 10, height = 6, dpi = 300)

data |>
  filter(a100_r == 0) |>
  ggplot(aes(y = unit.id, x = time.id)) + 
  geom_tile(aes(fill = treatment), colour = "white") +
  scale_fill_gradient(low = color.of.untreated, 
                      high = color.of.treated, guide = "legend", breaks = c(0, 
                                                                            1), 
                      labels = legend.labels) + 
  theme_bw() + 
  labs(title = title, 
       x = xlab, y = ylab, fill = "") + 
  theme(axis.ticks.x = element_blank(), 
        panel.grid.major = element_blank(), 
        panel.border = element_blank(), 
        legend.position = legend.position, 
        panel.background = element_blank(), 
        axis.text.x = element_text(angle = x.angle, size = x.size, 
                                   vjust = 0.5), 
        axis.ticks.y = element_blank(), 
        axis.text.y = element_blank(),   # Remove y-axis labels
        plot.title = element_text(hjust = 0.5))

ggsave(str_c(outputpath, "graphs/treatment_distribution_a100_0.png"), width = 10, height = 6, dpi = 300)









