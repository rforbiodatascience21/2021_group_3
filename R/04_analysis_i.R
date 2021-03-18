# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("cowplot")
library("broom")
library("purrr")
library("vroom")
library("tidyverse")

# Define functions --------------------------------------------------------
#source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
my_data_clean_aug <- read_tsv(file = "data/gravierbinarized_clean_aug.tsv")

# Wrangle data ------------------------------------------------------------
gravier_data_long = my_data_clean_aug %>%
  pivot_longer(cols = -value,
               names_to = "gene",
               values_to = "log2_expr_level")
gravier_data_long_nested = gravier_data_long %>%
  group_by(gene) %>%
  nest%>%
  ungroup
set.seed(934485)
gravier_data_long_nested = gravier_data_long_nested %>%
  sample_n(100)
gravier_data_long_nested =  gravier_data_long_nested %>%
  mutate(mdl = map(data, ~glm(value ~ log2_expr_level,
                              data = .x,
                              family = binomial(link = "logit"))))
gravier_data_long_nested = gravier_data_long_nested %>%
  mutate(mdl_tidy = map(mdl, tidy, conf.int =TRUE)) %>%
  unnest(mdl_tidy)
gravier_data_long_nested <- gravier_data_long_nested %>%
  filter(.,
         term == "log2_expr_level")
gravier_data_long_nested = gravier_data_long_nested %>%
  mutate(indentified_as = case_when(p.value < 0.05 ~ "Significant",
                                    TRUE ~ "Non-Significant"))
gravier_data_long_nested = gravier_data_long_nested %>%
  mutate(neg_log10_p = -log10(p.value))
gravier_data_wide = my_data_clean_aug %>%
  select(value, pull(gravier_data_long_nested, gene))
gravier_data_wide <- gravier_data_wide %>% mutate(value = as_factor(value))


# Model data
#my_data_clean_aug %>% ...


# Visualise data ----------------------------------------------------------
pca_fit <- gravier_data_wide %>% 
  select(where(is.numeric)) %>%
  prcomp(scale = TRUE)

p1 <- pca_fit %>%
  augment(gravier_data_wide) %>%
  ggplot(aes(.fittedPC1, .fittedPC2, color = value)) + 
  geom_point(size = 1.5) +
  theme_classic() + 
  theme(legend.position = "bottom")

arrow_style <- arrow(
  angle = 20, ends = "first", type = "closed", length = grid::unit(8, "pt")
)

p2 <- pca_fit %>%
  tidy(matrix = "rotation") %>%
  pivot_wider(names_from = "PC", names_prefix = "PC", values_from = "value") %>%
  ggplot(aes(PC1, PC2)) +
  geom_segment(xend = 0, yend = 0, arrow = arrow_style) +
  geom_text(
    aes(label = column),
    hjust = 1, nudge_x = -0.02, 
    color = "#904C2F"
  ) +
  xlim(-0.2, .2) + ylim(-.2, 0.2) +
  coord_fixed() + # fix aspect ratio to 1:1
  theme_minimal_grid(12)

p3 <- pca_fit %>%
  tidy(matrix = "eigenvalues") %>%
  filter(PC <= 10) %>%
  ggplot(aes(PC,
             percent)) +
  geom_col(fill = "#56B4E9",
           alpha = 0.8) +
  scale_x_continuous(breaks = 1:9) +
  scale_y_continuous(
    labels = scales::percent_format(),
    expand = expansion(mult = c(0, 0.4)),
    limits = c(0, 0.1)) +
  theme_minimal(base_size = 12,
                base_family = "")

# Write data --------------------------------------------------------------
ggsave(plot = p1, filename = "results/04_PCA_scatterplot.png", width = 16, height = 9, dpi = 72)
ggsave(plot = p2, filename = "results/04_PCA_arrowplot.png", width = 16, height = 9, dpi = 72)
ggsave(plot = p3, filename = "results/04_PCA_plot.png", width = 16, height = 9, dpi = 72)

