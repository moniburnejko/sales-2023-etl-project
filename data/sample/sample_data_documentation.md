# Sample Data Documentation

## 📁 Files Included

### 📊 sample_data_raw.xlsx
**Purpose:** Demonstrates original data quality issues before ETL transformation  
**Size:** ~15 KB  
**Rows:** 25 sales records, 15 products, 15 customers  
**Sheets:** Sales_Q1, Products, Customers

### ✅ sample_data_clean.xlsx  
**Purpose:** Shows the same data after complete ETL pipeline processing  
**Size:** ~18 KB  
**Rows:** Matching records from raw sample, fully transformed  
**Sheets:** Sales_2023, Products_Clean, Customers_Clean

## 🔍 Data Quality Issues Demonstrated

### In `sample_data_raw.xlsx`:

#### 1. **Date Format Chaos** (Sales_Q1 sheet)

| Format Type | Example | Count |
|------------|---------|-------|
| MM/DD/YY | `03/30/23` | 3 |
| MM/DD/YYYY | `03/03/2023` | 2 |
| DD/MM/YYYY | `28/01/2023` | 3 |
| DD.MM.YYYY | `01.02.2023` | 2 |
| YYYY/MM/DD | `2023/01/20` | 2 |
| YYYY-MM-DD | `2023-01-06` | 3 |
| DD-Mon-YYYY | `23-Jan-2023` | 2 |
| Excel Serial | `44937` | 8 |

#### 2. **Country Name Inconsistencies**

| Country | Variants Found |
|---------|---------------|
| Poland | `Poland`, `polska`, `PL`, `Polska`, `Republic of Poland` |
| Germany | `Germany`, `DE`, `Deutschland` |
| France | `France`, `FR`, `République française` |

#### 3. **Product Package Format Issues** (Products sheet)

| Original Format | Issue | Corrected Format |
|----------------|-------|------------------|
| `6 x 330ml` | Inconsistent spaces | `6 × 0.33 L` |
| `6x330ml` | No spaces | `6 × 0.33 L` |
| `1 kg` | Space before unit | `1 × 1 kg` |
| `0.5L` | Missing count | `1 × 0.5 L` |
| `500ml` | Non-standard unit | `1 × 0.5 L` |

#### 4. **Customer Data Problems** (Customers sheet)

**Email Issues:**
- Mixed cases: `Anna.Kowalski@GMAIL.com`
- Polish characters: `małgorzata.wiśniewski@example.pl`
- Invalid domains: `test@company`

**Phone Format Variations:**
- `+48 123-456-789`
- `+48123456789`
- `(+48) 123 456 789`
- `0048123456789`

#### 5. **Additional Issues**
- **Duplicate OrderIDs**: O1001, O1003, O1007 (15% duplication rate)
- **Text Casing**: `bbq ch1ps`, `BBQ Chips`, `Bbq CHIPS`
- **Decimal Separators**: Both `.` and `,` used
- **Typos**: "Laundry Liqud" → "Laundry Liquid"

### In `sample_data_clean.xlsx`:

#### ✅ **All Issues Resolved**

| Issue Category | Resolution Applied |
|---------------|-------------------|
| **Dates** | Standardized to YYYY-MM-DD (ISO 8601) |
| **Countries** | All variants → proper English names |
| **Packages** | Format: "N × X.XX Unit" |
| **Emails** | Lowercase, ASCII characters only |
| **Phones** | Format: +CountryCode###### |
| **Products** | Proper case, typos corrected |
| **Duplicates** | Removed (unique OrderIDs only) |
| **Calculated Fields** | Added SalesAmount = Qty × UnitPrice |

## 📊 Sample Data Statistics

### Raw Data Issues Found:
```
Total Issues Identified: 127
├── Date Format Issues: 25 (100% of dates)
├── Country Variations: 15 (60% of records)
├── Duplicate Records: 4 (15% of records)
├── Email Issues: 15 (100% of emails)
├── Package Inconsistencies: 15 (100% of products)
└── Other Issues: 53
```

### After Transformation:
```
Data Quality Score: 100%
├── Date Consistency: 100%
├── Country Standardization: 100%
├── Duplicate Removal: 100%
├── Email Validation: 100%
├── Package Normalization: 100%
└── Overall Completeness: 100%
```

## 🔧 ETL Functions Applied

The following custom Power Query M functions resolved these issues:

| Function | Purpose | Issues Resolved |
|----------|---------|----------------|
| `fxDate` | Date parsing | All 8 date format variations |
| `fxCountry` | Country standardization | 5+ variants per country |
| `fxText` | Text cleaning | Casing, typos, trimming |
| `fxNumber` | Number validation | Decimal separators |
| `fxLogical` | Boolean standardization | Yes/No/1/0/TRUE/FALSE |
| `fxDiacritics` | Character replacement | ą→a, ł→l, ę→e, etc. |

## 💡 How to Use These Samples

### 1. **For Learning**
Compare the raw and clean files side-by-side to understand each transformation:
```
Open both files → Compare same OrderID → See transformations applied
```

### 2. **For Testing**
Use the raw file to test Power Query functions:
```
Import raw data → Apply functions → Validate against clean data
```

### 3. **For Demonstration**
Show stakeholders the value of proper ETL:
```
Present raw data issues → Show transformation process → Display clean results
```

### 4. **For Documentation**
Reference specific examples in your portfolio:
```
"Handled 7+ date formats including Excel serials"
"Normalized package sizes from 5 different formats"
```

## 📝 Notes

- This is **synthetic data** created for portfolio demonstration
- All names, emails, and company information are fictitious
- Issues are based on real-world scenarios from actual business operations
- The full dataset contains 2,000+ records with similar patterns

## 🎯 Key Takeaway

> Even 25 rows of sample data contained **127 quality issues** requiring **50+ transformation rules**. The ETL pipeline successfully resolved 100% of these issues, demonstrating the value of systematic data cleaning.
