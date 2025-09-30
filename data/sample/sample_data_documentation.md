# Sample Data Documentation

## 📁 Files Included

### sample_data_raw.xlsx
**Purpose:** Demonstrates original data quality issues before ETL transformation  
**Size:** ~15 KB  
**Rows:** 25 sales records, 15 products, 15 customers

### sample_data_clean.xlsx  
**Purpose:** Shows the same data after complete ETL pipeline processing  
**Size:** ~18 KB  
**Rows:** Matching records from raw sample, fully transformed

## 🔍 Data Quality Issues Demonstrated

### In `sample_data_raw.xlsx`:

#### 1. **Date Format Chaos** (Sales_2023_Q1 sheet)
- `03/30/23` - MM/DD/YY format
- `03/03/2023` - MM/DD/YYYY format  
- `28/01/2023` - DD/MM/YYYY format
- `01.02.2023` - DD.MM.YYYY format
- `2023/01/20` - YYYY/MM/DD format
- `2023-01-06` - YYYY-MM-DD format
- `23-Jan-2023` - DD-Mon-YYYY format
- Excel serial numbers (e.g., 44937)

#### 2. **Country Name Inconsistencies**
- Multiple formats for Poland: `Poland`, `polska`, `PL`, `Polska`, `Republic of Poland`
- Mixed cases and languages throughout
- Inconsistent naming conventions

#### 3. **Product Package Format Issues** (Products sheet)
- `6 x 330ml` - spaces inconsistent
- `6x330ml` - no spaces
- `1 kg` - space before unit
- `1kg` - no space
- `0.5L` vs `500ml` - different units for same volume
- Mixed use of 'x' and '×' for multiplication

#### 4. **Customer Data Problems** (Customers sheet)
- Email addresses with mixed cases: `Anna.Kowalski@GMAIL.com`
- Polish characters in emails: `małgorzata.wiśniewski@example.pl`
- Phone formats: `+48 123-456-789`, `+48123456789`, `(+48) 123 456 789`
- Date formats in JoinDate field

#### 5. **Additional Issues**
- Duplicate OrderIDs (representing duplicate entries)
- Inconsistent text casing in product names: `bbq ch1ps`, `BBQ Chips`, `Bbq CHIPS`
- Mixed decimal separators: periods and commas
- Typos and spacing issues

### In `sample_data_clean.xlsx`:

#### ✅ **All Issues Resolved**
- **Dates:** Standardized to YYYY-MM-DD format
- **Countries:** All variants converted to proper names (e.g., all Polish variants → "Poland")
- **Packages:** Unified format "N × X.XX Unit" (e.g., "6 × 0.33 L")
- **Emails:** Lowercase, no Polish characters (ą→a, ł→l, etc.)
- **Phones:** Consistent format without separators
- **Products:** Proper casing, typos corrected
- **Duplicates:** Removed (only unique OrderIDs remain)
- **New calculated fields:** SalesAmount = Quantity × UnitPrice

## 📊 Sample Data Statistics

### Raw Data Issues Found:
- **7** different date formats
- **5** country name variations for Poland alone
- **15%** duplicate records (demonstrated with repeated OrderIDs)
- **100%** of emails needed standardization
- **Multiple** package format inconsistencies

### After Transformation:
- **100%** consistent date formatting
- **100%** standardized country names
- **0** duplicate records
- **100%** validated email formats
- **100%** standardized package sizes

## 🔧 ETL Functions Applied

The following custom Power Query M functions were used:
1. `fxDate` - Handled all date format variations
2. `fxCountry` - Standardized country names
3. `fxText` - Cleaned and standardized text fields
4. `fxNumber` - Handled decimal separators
5. `fxLogical` - Standardized boolean values
6. `fxDiacritics` - Replaced Polish characters

## 💡 How to Use These Samples

1. **For Learning:** Compare the raw and clean files side-by-side to understand transformations
2. **For Testing:** Use the raw file to test the Power Query functions
3. **For Demonstration:** Show stakeholders the value of data cleaning
4. **For Documentation:** Reference specific examples of issues and solutions

## 📝 Notes

- This is **synthetic data** created for portfolio demonstration
- All names, emails, and company information are fictitious
- Data patterns based on real-world scenarios encountered in business operations
- The full dataset contains 2,000+ records with similar issues

## 🎯 Key Takeaway

This sample demonstrates that even 25 rows of data can contain dozens of quality issues. The ETL pipeline successfully:
- Identified and categorized all data quality problems
- Applied appropriate transformation logic
- Produced clean, analysis-ready output
- Maintained data integrity throughout the process

*For the complete ETL pipeline code and documentation, see the main repository README.*
