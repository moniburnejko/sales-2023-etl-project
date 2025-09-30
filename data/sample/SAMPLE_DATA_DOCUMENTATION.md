# Sample Data Documentation - Sales 2023 ETL Project

## 📊 Overview
These sample files demonstrate the power of the ETL pipeline that transformed 8 fragmented, inconsistent sales data sources into a clean, relational data model. The samples showcase real-world data quality issues and their resolution through advanced Power Query techniques.

## 📁 Files Included

### `sample_data_raw.xlsx`
**Purpose:** Demonstrates original data quality issues before ETL transformation  
**Sheets:** Sales_2023_Q1, Sales_2023_Q2, Products, Customers  
**Records:** ~20-25 per sheet  
**File Size:** ~25 KB  

### `sample_data_clean.xlsx`
**Purpose:** Shows the same data after complete ETL pipeline processing  
**Sheets:** Sales_2023 (merged Q1+Q2), Products, Customers  
**Records:** Matching records from raw sample, fully transformed  
**File Size:** ~20 KB  

---

## 🔍 Data Quality Issues Demonstrated

### 1. **Sales Data Issues** (Raw: Sales_2023_Q1 & Sales_2023_Q2)

#### Date Format Chaos
The sample demonstrates **8 different date formats** found in the original data:
- `03/30/23` - MM/DD/YY format
- `3/25/2023` - M/DD/YYYY format  
- `03/03/2023` - MM/DD/YYYY format
- `28/01/2023` - DD/MM/YYYY format
- `01.02.2023` - DD.MM.YYYY format
- `2023/01/26` - YYYY/MM/DD format
- `2023-01-05` - YYYY-MM-DD format
- `03-Jun-2023` - DD-Mon-YYYY format
- `44937` - Excel serial number
- `null` - Missing dates

**Resolution:** Custom `fxDate` function handles all formats → standardized to `YYYY-MM-DD`

#### Column Name Inconsistencies Between Quarters
- Q1: `OrderID`, `OrderDate`, `CustomerID`, `ProductSKU`
- Q2: `Order_ID`, `Date`, `CustID`, `SKU`

**Resolution:** Column mapping and standardization during append operation

#### Duplicate Records
- Sample shows duplicate `OrderID: O312146` appearing twice in Q1
- Represents ~15% duplicate rate found in full dataset

**Resolution:** Group by OrderID, keep first occurrence

#### Numeric Format Issues
- Mixed decimal separators: `175.26` vs `175,26`
- Missing decimals: `63` instead of `63.00`

**Resolution:** `fxNumber` function handles both `.` and `,` as decimal separators

#### Country Name Variations
Multiple formats for same countries:
- Poland: `Poland`, `polska`, `PL`, `poland`, `Polska`
- Czech Republic: `czechia`, `Czechia`, `Czech Republic`
- Germany: `Germany`, `GERMANY`, `germany`

**Resolution:** `fxCountry` function maps all variations to standard names

#### Inconsistent Salesperson Names
- Case variations: `E. Dabrowska`, `e. dabrowska`, `E. DABROWSKA`
- Polish characters: `E. Dąbrowska` vs `E. Dabrowska`
- Missing values: `null`, `—`, empty strings

**Resolution:** `fxText` function + standardization rules

---

### 2. **Products Data Issues** (Raw: Products sheet)

#### Package Size Format Chaos
The sample shows various formats that needed parsing:
- Space inconsistencies: `6 x 330ml` vs `6x330ml` vs `6 x 330 ml`
- Different units: `500g` vs `0.5 kg`, `330ml` vs `0.33L`
- Multiplication symbols: `x` vs `×` 
- Mixed formats: `24x330 ml`, `12 x 0.5L`, `1kg`

**Resolution:** Complex parsing algorithm that:
1. Extracts pack count (default: 1)
2. Separates value and unit
3. Converts to base units (ml→L, g→kg)
4. Standardizes to format: `N × X.XX Unit`

#### Product Name Issues
- Typos: `bbq ch1ps`, `Almond m1x`
- Inconsistent casing: `BBQ Chips`, `Bbq CHIPS`, `bbq chips`
- Extra spaces: `Green  Tea`
- Special characters: `Kitchen_Towels`

**Resolution:** `fxText` function for cleaning + manual corrections

#### Boolean Value Inconsistencies (Active field)
Multiple representations of true/false:
- True: `TRUE`, `Yes`, `Y`, `1`
- False: `FALSE`, `No`, `N`, `0`

**Resolution:** `fxLogical` function maps all variations to boolean

#### Duplicate SKUs
- `P2824-A` appears twice with different data
- Represents data integrity issues

**Resolution:** Remove duplicates keeping first occurrence

#### EAN Code Issues
- Inconsistent lengths (not all 13 digits)
- Some with leading zeros stripped

**Resolution:** Validation and padding to ensure 13-digit format

---

### 3. **Customers Data Issues** (Raw: Customers sheet)

#### Email Address Problems
- Mixed cases: `Ola.Lewandowski@FIRMA.pl`
- Polish diacritics: `magda.wiśniewski@example.pl`, `ania.woźniak@mail.com`
- Inconsistent domains and formatting

**Resolution:** 
1. Convert to lowercase
2. `fxDiacritics` replaces: ą→a, ć→c, ę→e, ł→l, ń→n, ó→o, ś→s, ź→z, ż→z

#### Phone Number Formatting
Various formats in the sample:
- `+49 177 395-5087` - spaces and dashes
- `+48 189 735832` - spaces only
- `+420906917853` - no formatting
- `+420 549 227386` - inconsistent spacing

**Resolution:** Remove all non-numeric characters except leading `+`

#### Join Date Formats
Multiple date formats similar to sales data:
- `3/20/2023` - M/DD/YYYY
- `11.01.2018` - DD.MM.YYYY
- `10-08-2022` - DD-MM-YYYY
- `18-Mar-2021` - DD-Mon-YYYY
- `2022-12-16` - YYYY-MM-DD
- `2019/06/02` - YYYY/MM/DD

**Resolution:** `fxDate` function handles all variations

#### Country Standardization
- `polska` → `Poland`
- `PL` → `Poland`
- `czechia` → `Czechia`
- `germany` → `Germany`

**Resolution:** `fxCountry` mapping function

---

## ✅ Clean Data Results

### Sales_2023 (Merged & Cleaned)
- **25 clean records** from Q1 and Q2 combined
- **Standardized dates:** All in YYYY-MM-DD format
- **Deduplicated:** No duplicate OrderIDs
- **Enriched:** CustomerName, Email, Phone from Customer dimension
- **Calculated field:** SalesAmount = Qty × UnitPrice
- **Consistent formatting:** All text fields properly cased

### Products (Cleaned)
- **20 unique products** after deduplication
- **Package sizes:** Standardized to "N × X.XX Unit" format
- **Boolean values:** Converted to TRUE/FALSE
- **Product names:** Typos corrected, consistent casing
- **EAN codes:** Validated 13-digit format

### Customers (Cleaned)
- **20 customer records** with standardized data
- **Emails:** Lowercase, no diacritics
- **Phone numbers:** Consistent international format
- **Dates:** All in YYYY-MM-DD format
- **Countries:** Standardized names

---

## 🎯 Key Transformations Applied

### Custom Power Query Functions Used:
1. **fxDate** - Handles 8+ date format variations
2. **fxNumber** - Manages decimal separator issues
3. **fxText** - Cleans and standardizes text
4. **fxCountry** - Maps country name variations
5. **fxLogical** - Standardizes boolean values
6. **fxDiacritics** - Removes Polish special characters

### Transformation Statistics:
- **Date formats unified:** 8 different formats → 1 standard format
- **Duplicates removed:** ~15% of records
- **Country variations:** 5+ per country → standardized
- **Package formats:** 10+ variations → unified format
- **Boolean representations:** 8 variations → TRUE/FALSE

---

## 💡 Why This Matters

This sample demonstrates that even a small dataset (25 rows) can contain **50+ distinct data quality issues**. The ETL pipeline successfully:

1. **Identified** all data quality problems systematically
2. **Categorized** issues by type and impact
3. **Applied** appropriate transformation logic
4. **Validated** results for consistency
5. **Maintained** data integrity throughout

The same techniques scale to the full dataset of 2,000+ records, where these issues compound exponentially.

---

## 📈 Business Impact

### Before ETL:
- ❌ Cannot merge quarterly data (incompatible schemas)
- ❌ Cannot aggregate by country (5+ name variations each)
- ❌ Cannot calculate accurate totals (duplicates)
- ❌ Cannot compare products (inconsistent units)
- ❌ Cannot perform date analysis (8 formats)

### After ETL:
- ✅ Unified sales view across all quarters
- ✅ Accurate country-level analysis
- ✅ Reliable financial calculations
- ✅ Standardized product comparisons
- ✅ Time-series analysis enabled

---

## 🔧 Technical Implementation

### Power Query M Code Structure:
```m
// Example: fxDate function logic
(dateValue as any) as date =>
let
    // Handle various date formats
    Result = 
        if dateValue = null or Text.Trim(dateValue) = "" then null
        else if Value.Is(dateValue, type number) then Date.From(dateValue)
        else [Complex parsing logic for 8+ formats]
in
    Result
```

### Transformation Pipeline:
1. **Extract** → Load raw Excel files
2. **Clean** → Apply custom functions
3. **Transform** → Standardize, deduplicate, calculate
4. **Merge** → Combine related data
5. **Load** → Output clean dataset

---

## 📝 Notes

- This is **synthetic data** created for portfolio demonstration
- All names, emails, and company information are fictitious
- Data patterns based on real-world ETL challenges
- The full dataset contains similar issues at scale (2,000+ records)

---

## 🚀 Repository Usage

1. **Compare files side-by-side** to understand transformations
2. **Use as test data** for Power Query functions
3. **Reference for documentation** of ETL processes
4. **Demonstration** of data quality improvement value

---

*For complete ETL pipeline code and full documentation, see the main repository README.*
