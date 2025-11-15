# ============================================================
# Rkive Topographical & Market Analysis – Initial Exploration
# Author: AnalytiQ Team
# ============================================================

# --- Packages ---
suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(scales)
  library(stringr)
  library(forcats)
  library(here)
})

# ============================================================
# Rkive palette + theme
# ============================================================
rkive_soft <- list(
  deep_denim = "#1B2B44",
  soft_blue  = "#4A8FE7",
  sky_blue   = "#7EB6F6",
  mist_gray  = "#CBD5E1",
  slate_gray = "#8FA1B3",
  white      = "#FFFFFF"
)

theme_rkive <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title        = element_text(face = "bold", color = rkive_soft$soft_blue),
      axis.title        = element_text(face = "bold", color = rkive_soft$deep_denim),
      axis.text         = element_text(color = rkive_soft$deep_denim),
      panel.grid.major  = element_line(color = rkive_soft$mist_gray),
      panel.grid.minor  = element_blank(),
      legend.position   = "bottom"
    )
}

# ============================================================
# Robust paths 
# ============================================================
pick_path <- function(candidates, ask_msg) {
  existing <- Filter(file.exists, candidates)
  if (length(existing) > 0) return(existing[[1]])
  message(ask_msg)
  return(file.choose())
}

# If this is an Rmd, keep the file name below; if a script, you can remove i_am()
try(here::i_am("rkive_analysis.R"), silent = TRUE)

bills_path <- pick_path(
  c(here("bills_data(in).csv"), "bills_data(in).csv"),
  "Select bills_data(in).csv"
)
items_path <- pick_path(
  c(here("Invoice_Line_Items(in).csv"), "Invoice_Line_Items(in).csv"),
  "Select Invoice_Line_Items(in).csv"
)

# ============================================================
# 1) ANALYSIS A – Regional Activity (bills_data)
# ============================================================
bills <- readr::read_csv(bills_path, show_col_types = FALSE)

bills_clean <- bills %>%
  rename(
    bill_id  = id...2,
    city     = supplier_city,
    total    = total_amount,
    tax      = total_tax_amount,
    payment  = payment_type,
    supplier = supplier_name
  ) %>%
  mutate(
    created_at = parse_date_time(created_at, orders = "b d, Y, I:M:Sp", tz = "UTC"),
    total      = suppressWarnings(as.numeric(total)),
    tax        = suppressWarnings(as.numeric(tax)),
    city       = str_to_title(str_squish(city))
  ) %>%
  filter(!is.na(city) & total > 0)

city_summary <- bills_clean %>%
  group_by(city) %>%
  summarise(
    receipts_uploaded = n_distinct(bill_id),
    total_spent       = sum(total, na.rm = TRUE),
    avg_spent         = mean(total, na.rm = TRUE),
    avg_tax           = mean(tax, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(receipts_uploaded))

print(city_summary)

# Top 10 cities by traffic (horizontal for readability)
p_receipts <- city_summary %>%
  slice_max(receipts_uploaded, n = 10) %>%
  ggplot(aes(x = fct_reorder(city, receipts_uploaded),
             y = receipts_uploaded,
             label = comma(receipts_uploaded))) +
  geom_col(fill = rkive_soft$soft_blue, width = 0.7) +
  geom_text(hjust = -0.1, size = 4, color = rkive_soft$deep_denim, fontface = "bold") +
  coord_flip(clip = "off") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = "Top 10 Cities by Receipt Uploads", x = "City", y = "Receipts Uploaded") +
  theme_rkive() +
  theme(plot.margin = margin(10, 30, 10, 10))
print(p_receipts)
ggsave("top10_cities_receipts.png", p_receipts, width = 9, height = 6, dpi = 300)

# Total spending by city (top 10, horizontal)
p_spend <- city_summary %>%
  slice_max(total_spent, n = 10) %>%
  ggplot(aes(x = fct_reorder(city, total_spent), y = total_spent)) +
  geom_col(fill = rkive_soft$sky_blue, width = 0.7) +
  coord_flip() +
  scale_y_continuous(labels = label_dollar(accuracy = 1)) +
  labs(title = "Total Spending by City", x = "City", y = "Total Amount ($)") +
  theme_rkive()
print(p_spend)

# Weekly upload trend
p_weekly <- bills_clean %>%
  mutate(week = floor_date(as_date(created_at), "week")) %>%
  count(week) %>%
  ggplot(aes(x = week, y = n)) +
  geom_col(fill = rkive_soft$sky_blue, width = 6) +
  geom_text(aes(label = n), vjust = -0.3, size = 3.5, color = rkive_soft$deep_denim) +
  labs(title = "Weekly Receipt Uploads", x = NULL, y = "Total Receipts") +
  theme_rkive()
print(p_weekly)

bills_kpi <- bills_clean %>%
  summarise(
    total_receipts    = n_distinct(bill_id),
    total_cities      = n_distinct(city),
    avg_receipt_value = mean(total, na.rm = TRUE),
    total_spent       = sum(total, na.rm = TRUE)
  )
print(bills_kpi)

# ============================================================
# 2) ANALYSIS B – Product / Price Trends (Invoice_Line_Items)
# ============================================================
items <- readr::read_csv(items_path, show_col_types = FALSE)

items_clean <- items %>%
  rename(product = item, bill_id = bill_id, price = price) %>%
  mutate(
    product = str_squish(product),
    price   = readr::parse_number(as.character(price))
  ) %>%
  filter(!is.na(product) & !is.na(price) & price > 0) %>%
  mutate(
    product = case_when(
      str_detect(product, regex("^14[- ]?inch\\s+mac\\s*book\\s*pro", TRUE)) ~
        "14 inch mac book pro",
      TRUE ~ product
    )
  )

top_products_value <- items_clean %>%
  group_by(product) %>%
  summarise(total_value = sum(price, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(total_value)) %>%
  slice_head(n = 10)

stopifnot(nrow(top_products_value) > 0)

# Top 10 Products by Total Value — horizontal, wrapped labels
p_products <- top_products_value %>%
  mutate(product_wrapped = stringr::str_wrap(product, width = 28)) %>%
  ggplot(aes(x = forcats::fct_reorder(product_wrapped, total_value),
             y = total_value)) +
  geom_col(fill = rkive_soft$soft_blue, width = 0.7) +
  geom_text(aes(label = scales::dollar(total_value, accuracy = 1)),
            hjust = -0.1, size = 3.8, color = rkive_soft$deep_denim, fontface = "bold") +
  coord_flip(clip = "off") +
  scale_y_continuous(labels = scales::label_dollar(accuracy = 1),
                     expand = expansion(mult = c(0, 0.15))) +  # sağa boşluk
  labs(title = "Top 10 Products by Total Value",
       x = "Product",
       y = "Total Sales ($)") +
  theme_rkive() +
  theme(
    plot.margin = margin(10, 30, 10, 10),
    axis.text.y = element_text(size = 10)  # okunaklı y-etiketleri
  )

print(p_products)


# Price density
p_density <- ggplot(items_clean, aes(price)) +
  geom_density(fill = rkive_soft$sky_blue, alpha = 0.4) +
  scale_x_log10(labels = label_dollar()) +
  labs(title = "Price Density (Log Scale)", x = "Price ($, log scale)", y = "Density") +
  theme_rkive()
print(p_density)

# ============================================================
# Save all visual outputs (Rkive Analysis)
# ============================================================

# Create a folder named 'outputs' if it doesn't exist
if (!dir.exists("outputs")) dir.create("outputs")

# List all ggplot objects you want to save
plots_to_save <- list(
  "top10_cities_receipts" = p_receipts,
  "total_spending_city"   = p_spend,
  "weekly_uploads"        = p_weekly,
  "top_products_value"    = p_products,
  "price_density"         = p_density
)

# Loop through and save each plot in both PNG and PDF formats
for (name in names(plots_to_save)) {
  ggsave(
    filename = file.path("outputs", paste0(name, ".png")),
    plot = plots_to_save[[name]],
    width = 9, height = 6, dpi = 300
  )
  ggsave(
    filename = file.path("outputs", paste0(name, ".pdf")),
    plot = plots_to_save[[name]],
    width = 9, height = 6
  )
}

message("\n All Rkive visualizations have been saved in the 'outputs' folder.")

