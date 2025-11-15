# 📊 Rkive – Macro Tec Systems Inc.  
### MSBA Capstone Project | AnalytiQ Team (Aybüke, Reeta, Ashish)

This repository contains the full data analytics, visualization workflow, and reporting materials developed for the **Rkive Personal Expense Management Tool**, created by **Macro Tec Systems Inc.** as part of the **Master of Science in Business Analytics Capstone Project**.

Our project integrates **data cleaning, encryption, financial insights, macroeconomic indicators, and user behavior analysis** to provide strategic recommendations for Rkive’s U.S. market expansion.

---

## 🔍 **Project Overview**
Rkive is an AI-supported **personal expense management platform** that automatically extracts, encrypts, and analyzes financial data from receipts and invoices.

Our capstone team focused on:
- Understanding consumer spending patterns  
- Linking micro-level expenses with macro-level inflation indicators  
- Designing a secure workflow for data handling and encryption  
- Recommending market strategies for product positioning  
- Creating data-driven insights to guide business decisions  

This repository includes the complete analytical workflow performed in **R**, following reproducible and ethical data science practices.

---

## 🗂️ **Repository Structure**

Rkive-MacroTec-Analysis/
│
├── data/
│ ├── bills_data(in).csv
│ ├── Invoice_Line_Items(in).csv
│ ├── state_retail_yy.csv
│ ├── cu-region-1-year-average-2023.xlsx
│
├── code/
│ ├── EDA_rkive.R
│ ├── encrypt_R_data.R
│ ├── ANALYTIQ_MACROTECSYSTEM_Analysis.Rmd
│
├── report/
│ ├── ANALYTIQ_MACROTECSYSTEM_Report.docx
│
└── README.md


**Note:** Data files include synthetic or anonymized information for academic purposes.

---

## 🛠️ **Tech Stack & Packages Used**

### **Languages**
- R  
- Markdown / R Markdown  

### **Key R Libraries**
- `tidyverse`  
- `dplyr`  
- `lubridate`  
- `ggplot2`  
- `scales`  
- `stringr`  
- `forcats`  
- `sodium` (for encryption)

---

## 🔐 **Data Encryption Workflow**
Rkive incorporates a privacy-sensitive workflow using the `sodium` package:

- Automatic encryption of receipt and invoice data  
- Secure storage of sensitive values  
- Decryption only for analytical steps  
- End-to-end reproducible script: **encrypt_R_data.R**

This demonstrates real-world data compliance and ethical data handling.

---

## 📈 **Analysis Components**
The analysis focuses on:

### **1. Expense Categorization**
- Item-level aggregation  
- Purchase frequency  
- Category-level spending trends  

### **2. Macroeconomic Alignment**
Integrating **Consumer Price Index (CPI)** and retail inflation data to examine:
- Category-level price changes  
- Spending elasticity  
- Month-over-month inflation shifts  
- Comparison of CPI inflation vs user spending behavior  

### **3. Market & Product Insights**
- User adoption characteristics  
- Financial behavior patterns  
- Strategic implications for Rkive’s U.S. market presence  

All visuals are generated using **ggplot2** with a clean, business-oriented design.

---
---

## 🎨 Presentation 
View the visual slide deck on Canva:  
👉 **https://www.canva.com/design/DAG3HNmVZwg/ZQdXp0YuHHTZ23XQb-tHSQ/edit?utm_content=DAG3HNmVZwg&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton**

---

## 🎯 **Purpose of This Repository**
This GitHub repository was created to:
- Demonstrate end-to-end analytics capability  
- Showcase real-world data handling & security  
- Provide future employers a transparent view of technical skills  
- Document the MSBA capstone work process  

---

## 📬 Contact
For questions or collaboration:  
**aybukeyildizolmez@gmail.com**


