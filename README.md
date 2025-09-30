# Sales 2023 Data Wrangling & ETL Project 🔧

## Project Overview
Enterprise-level data transformation project converting fragmented, inconsistent sales data into a clean, relational analytical model using advanced Power Query techniques.

**Key Achievement:** Transformed 8 fragmented sales files (2,000+ records) with severe quality issues into a production-ready star schema, eliminating 15% duplicates and standardizing 50+ format inconsistencies.

## 📊 Business Problem
Sales operations generated data across 8 separate sources with critical quality issues preventing reliable analysis:
- **Data Fragmentation:** Multiple disconnected files (transactions, products, customers, returns, fees, shipping, targets)
- **Quality Issues:** Duplicates, inconsistent formats, conflicting units, typos
- **Integration Complexity:** Multiple records per OrderID causing merge complications
- **Partial Coverage:** Country-specific data requiring careful relational design

## 🛠 Technical Solution

### Technologies Used
- **Microsoft Excel** - Data storage and final output
- **Power Query** - ETL engine
- **M Language** - Custom transformation functions
- **Data Modeling** - Star schema design

### Custom Functions Developed
Created 6 reusable M language functions for robust data transformation:
1. **fxDate** - Handles mixed date formats and invalid dates
2. **fxNumber** - Validates numeric data with decimal separator handling  
3. **fxText** - Standardizes text fields and removes special characters
4. **fxCountry** - Consolidates country name variants
5. **fxLogical** - Standardizes boolean values (Yes/No/1/0/TRUE/FALSE)
6. **fxDiacritics** - Replaces Polish characters for system compatibility

### Key Transformations
- **50+ cleaning operations** across all data sources
- **Complex unit parsing** - Converted mixed formats (6x330ml, 0.5L, 500g) to standardized units
- **Composite field splitting** - Parsed concatenated strings into structured fields
- **Wide-to-long transformation** - Restructured targets data for analysis
- **Deduplication logic** - Removed duplicates while preserving data integrity

## 📁 Data Sources & Outputs

### Data Sources

This project uses synthetic sales data created to simulate real-world business scenarios and data quality issues. The dataset includes:
- 2,000+ synthetic transactions
- Realistic Polish customer names and addresses  
- Intentional data quality issues for ETL demonstration
- Business patterns based on real retail scenarios

**Note:** All data is completely synthetic and safe for public sharing.

### Input Files (8 sources)
| Source | Records | Key Issues |
|--------|---------|------------|
| Sales Q1 & Q2 | ~850 | Duplicates, inconsistent dates, mismatched columns |
| Products | ~100 | Mixed package formats, typos, duplicate SKUs |
| Customers | ~200 | Inconsistent formats, unvalidated data |
| Returns | ~50 | Inconsistent reason text, mixed date formats |
| Fees | ~20 | Duplicates, Poland-only coverage |
| Shipping | ~150 | Composite text fields, unstructured data |
| Targets | ~12 | Wide format requiring unpivot |

### Output Structure
**Star Schema with:**
- 1 Fact Table (Sales_2023)
- 2 Dimension Tables (Products, Customers)  
- 4 Supporting Tables (Returns, Fees, Shipping, Targets)

## 🎯 Results & Impact

### Data Quality Improvements
- **Eliminated 15%+ duplicate records** across all tables
- **Standardized 50+ format variants** (dates, countries, currencies)
- **100% data validation** - All dates, numbers, and EANs verified
- **Unified measurement systems** - Consistent units across products

### Business Value Delivered
- **Unified View:** Consolidated fragmented data for complete 2023 visibility
- **Analysis Ready:** Clean data model enabling immediate business intelligence
- **Scalable Solution:** Reusable functions for future data ingestion
- **Time Savings:** Automated cleaning process replacing manual work

## 📸 Before & After Examples

### Sales Data Transformation
- **Before:** Duplicates, mixed date formats, inconsistent country names
- **After:** Clean, standardized records with validated data types

### Products Normalization
- **Before:** "6x330ml", "24 × 330 ml", "0.5L", "500g" 
- **After:** Standardized format "6 × 0.33 L"
  
### Shipping Data Parsing
- **Before:** "DPD | Express | 2–4d"
- **After:** Separate fields for Carrier, DeliveryType, EstimatedDays

## 🚀 How to Use

1. **Download the cleaned dataset** from `/data/processed/`
2. **Review the data dictionary** in `/documentation/`
3. **Apply custom functions** from `/queries/` to your own data
4. **Follow the ETL pipeline guide** for step-by-step transformation

## 📚 Repository Structure

```
├── data/               # Raw and processed datasets
├── documentation/      # Detailed project documentation
├── queries/           # Power Query M code and functions
├── images/            # Screenshots and diagrams
└── analysis/          # Data quality reports
```

## 💡 Key Learnings

- **Data Quality First:** 80% of effort went into cleaning and standardization
- **Reusable Functions:** Custom M functions dramatically reduce future ETL time
- **Relational Design:** Proper table separation prevents null proliferation
- **Documentation:** Clear documentation ensures reproducibility

## 🔗 Project Links

- [Full Project Documentation](https://www.notion.so/monikaburnejko/Sales-2023-Data-Wrangling-ETL-Project-27b1bac67ca980c5b844c13fc59d1f7c)
- [LinkedIn Profile](https://www.linkedin.com/in/monika-burnejko-9301a1357)
- [Portfolio](https://www.notion.so/monikaburnejko/Data-Analytics-Portfolio-2761bac67ca9807298aee038976f0085)
