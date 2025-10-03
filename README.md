# Sales 2023 Data Wrangling & ETL Project 🔧

[![Excel](https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)](https://www.microsoft.com/excel)
[![Power Query](https://img.shields.io/badge/Power_Query-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerquery.microsoft.com/)

## Project Overview

Enterprise-level data transformation project converting **8 fragmented sales files** with severe quality issues into a **production-ready star schema**, eliminating **15% duplicates** and standardizing **50+ format inconsistencies**.

### Key Achievement
> Transformed 2,000+ records of chaotic multi-source data into a clean, relational analytical model using advanced Power Query techniques and custom M functions, reducing data processing time from hours to minutes.

## Business Problem

Sales operations generated data across 8 separate sources with critical quality issues preventing reliable analysis:

| Challenge | Impact | 
|-----------|--------|
| **Data Fragmentation** | 8 disconnected files preventing holistic analysis |
| **Quality Issues** | 15%+ duplicate records, 50+ format variants |
| **Integration Complexity** | Multiple records per OrderID causing merge complications |
| **Partial Coverage** | Country-specific data requiring careful relational design |

## Technical Solution

### Tech Stack
- **Microsoft Excel** - Data storage and final output
- **Power Query** - ETL engine
- **M Language** - Custom transformation functions  
- **Data Modeling** - Star schema design

### Custom Functions Developed

Created **8 reusable M language functions** for robust data transformation:

| Function | Purpose | Issues Resolved |
|----------|---------|----------------|
| `fxClean` | Table cleaning & standardization | Clean headers, remove blanks, unify columns |
| `fxDate` | Date parsing | 7+ mixed date formats |
| `fxNumber` | Numeric validation | Decimal separator conflicts |
| `fxText` | Text cleaning & normalization | Unwanted symbols, extra spaces, inconsistent casing |
| `fxCountry` | Country consolidation | 5+ variants per country |
| `fxLogical` | Boolean standardization | Yes/No/1/0/TRUE/FALSE |
| `fxDiacritics` | Character replacement | Polish special characters |
| `fxPackageSize` | Package size format standardization | Package format chaos |
 

### Transformation Pipeline

```
8 Raw Files → Power Query → Custom Functions → 50+ Transformations → Validation → Star Schema
```

## Project Structure

```
sales-2023-etl-project/
├── 📂 data/
│   ├──📂 sample/               # Sample datasets demonstrating transformation
│   └── README.md               # Data documentation
├── 📂 documentation/
│   ├── data_dictionary.md      # Comprehensive field documentation
│   ├── data_model.md           # Star schema design details
│   ├── data_model_diagram.png  # Data modeling diagram
│   └── etl_pipeline.md         # Step-by-step transformation guide
├── 📂 queries/
│   └── power_query_functions.m # Reusable M code functions
└── 📂 images/
    └── 📂 transformations/     # Before/after screenshots
```

## Results & Impact

### Data Quality Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Duplicate Records** | 15%+ | 0% | 100% eliminated |
| **Format Variants** | 50+ | 0 | 100% standardized |
| **Invalid Dates** | 12% | 0% | 100% parsed |
| **Orphaned Records** | 8% | 0% | 100% validated |
| **Processing Time** | Manual (hours) | < 2 minutes | 98% reduction |

### Business Value Delivered

- **Unified View** - Consolidated fragmented data for complete 2023 visibility  
- **Analysis Ready** - Clean data model enabling immediate BI implementation  
- **Scalable Solution** - Reusable functions for future data ingestion  
- **Time Savings** - Automated cleaning replacing manual work  

## Transformation Examples

### Before & After Snapshots

<details>
<summary>Click to see transformation examples</summary>

#### Date Standardization
```
Before: 03/30/23, 28.01.2023, 2023-Jan-06, 44937 (Excel serial)
After:  2023-03-30
```

#### Product Package Normalization  
```
Before: "6x330ml", "24 × 330 ml", "0.5L", "500g"
After:  "6 × 0.33 L" (standardized format)
```

#### Shipping Data Parsing
```
Before: "DPD | Express | 2–4d"
After:  Carrier: DPD, DeliveryType: Express, EstimatedDeliveryDays: 2-4
```
</details>

## How to Use This Project

### Prerequisites
- Microsoft Excel 2016+ with Power Query
- Basic understanding of ETL concepts

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/moniburnejko/sales-2023-etl-project.git
   ```

2. **Open sample data**
   - Navigate to `/data/sample/`
   - Open `sample_data_raw.xlsx` to see original data issues
   - Open `sample_data_clean.xlsx` to see transformed results

3. **Apply transformations**
   - Import custom functions from `/queries/power_query_functions.m`
   - Follow the pipeline guide in `/documentation/etl_pipeline.md`

## Documentation

| Document | Description |
|----------|-------------|
| [Data Dictionary](documentation/data_dictionary.md) | Complete field specifications and business rules |
| [Data Model](documentation/data_model.md) | Star schema design and relationships |
| [ETL Pipeline](documentation/etl_pipeline.md) | Step-by-step transformation guide |
| [Sample Data Guide](data/sample/sample_data_documentation.md) | Examples of issues and solutions |

## Key Learnings

This project reinforced several critical data engineering principles:

1. **Data Quality First** - 80% of effort goes into cleaning and standardization
2. **Reusable Functions** - Custom M functions dramatically reduce future ETL time
3. **Relational Design** - Proper table separation prevents null proliferation
4. **Documentation** - Clear documentation ensures reproducibility

## Connect

**Monika Burnejko** - Data Analyst  
📧 [monikaburnejko@gmail.com](mailto:monikaburnejko@gmail.com)  
💼 [LinkedIn](https://www.linkedin.com/in/monika-burnejko-9301a1357)  
🌐 [Portfolio](https://www.notion.so/monikaburnejko/Data-Analytics-Portfolio-2761bac67ca9807298aee038976f0085)

## License

This project uses synthetic data created for portfolio demonstration. All data is fictional and safe for public sharing.

---

<p align="center">
⭐ If you found this project helpful, please consider giving it a star!
</p>
