# ==========================================================
# 🔐 Encrypt sensitive fields in bills_clean (in-memory)
# ==========================================================

library(dplyr)
library(purrr)
library(sodium)
library(digest)

# --- 1️⃣ Create an in-memory encryption key ---
set.seed(123)
key <- random(32)  # 256-bit AES key

# --- 2️⃣ Helper functions ---
enc_hex <- function(x, key) {
  if (is.na(x) || x == "") return(NA_character_)
  bin2hex(simple_encrypt(charToRaw(as.character(x)), key))
}

dec_hex <- function(x_hex, key) {
  if (is.na(x_hex) || x_hex == "") return(NA_character_)
  rawToChar(simple_decrypt(hex2bin(x_hex), key))
}

salt <- "rotate-this-salt-regularly"
tok <- function(x) ifelse(is.na(x) | x == "", NA_character_,
                          digest(paste0(salt, ":", x), algo = "sha256"))

# --- 3️⃣ Define sensitive columns based on your dataset ---
pii_cols   <- c("supplier", "payment")   # encrypt
token_cols <- c("bill_id", "id...8")     # hash

# --- 4️⃣ Apply tokenization + encryption ---
bills_secure <- bills_clean %>%
  mutate(
    across(all_of(token_cols), \(x) tok(x), .names = "{.col}_token"),
    across(all_of(pii_cols),   \(x) map_chr(x, enc_hex, key = key), .names = "{.col}_enc")
  ) %>%
  select(-all_of(pii_cols))  # drop plaintext supplier/payment

# --- 5️⃣ Preview the encrypted result ---
glimpse(bills_secure)
head(bills_secure)

cat("\n✅ bills_clean successfully encrypted → new object 'bills_secure' created.\n")

# --- 6️⃣ (Optional) Decrypt one example to verify ---
dec_hex(bills_secure$supplier_enc[1], key)
