# 📁 Data Directory

## Overview

This directory contains synthetic sales data demonstrating real-world ETL challenges and their solutions.

## Directory Structure
```
data/
├── sample/                     
│   ├── sample_data_raw.xlsx          # Original messy data
│   ├── sample_data_clean.xlsx        # Transformed clean data
│   └── sample_data_documentation.md  # Detailed issue documentation
└── README.md                         # This file
```

## Dataset Information

### Important Notice
**This project uses 100% synthetic data generated for demonstration purposes.**

All names, addresses, email addresses, and company information are fictitious. Any resemblance to real persons, companies, or actual transactions is purely coincidental.

## Sample Data Details

### sample_data_raw.xlsx
- **Purpose:** Demonstrates original data quality issues
- **Size:** ~25 KB
- **Records:** 25 sales, 20 products, 20 customers
- **Issues Demonstrated:**
  - 7 different date formats
  - 5 country name variations
  - Mixed package formats
  - Duplicate records
  - Inconsistent text casing

### sample_data_clean.xlsx
- **Purpose:** Shows data after complete ETL pipeline
- **Size:** ~20 KB  
- **Improvements:**
  - 100% standardized dates
  - Unified country names
  - Normalized package sizes
  - Zero duplicates
  - Calculated fields added

## Data Quality Issues Simulated

The synthetic data intentionally includes common real-world problems:

| Issue Category | Examples | Count |
|---------------|----------|-------|
| **Date Formats** | MM/DD/YY, DD-Mon-YYYY, Excel serials | 7+ formats |
| **Duplicates** | Repeated OrderIDs | 15% of records |
| **Text Inconsistency** | "Poland", "polska", "PL" | 50+ variants |
| **Unit Confusion** | "6x330ml" vs "0.33L x 6" | Multiple formats |
| **Character Issues** | Mixed cases, Polish diacritics | 100% of text fields |

## How to Use

1. **For Learning**: Compare raw vs clean files to understand transformations
2. **For Testing**: Apply Power Query functions to raw data
3. **For Demonstration**: Show stakeholders the value of proper ETL
4. **For Practice**: Try creating your own cleaning functions

## Full Dataset Statistics

While samples contain 25 records, the full project processed:
- **2,000+** transaction records
- **8** separate data sources
- **50+** unique transformation rules
- **7** custom M functions

---

*For detailed transformation documentation, see [sample_data_documentation.md](sample/sample_data_documentation.md)*
