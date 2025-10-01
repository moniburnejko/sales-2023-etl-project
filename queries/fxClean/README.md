# fxClean - Universal Data Cleaning Function

## Purpose
Automates the three most common data cleaning operations in Power Query: removing empty rows, trimming whitespace, and standardizing column names.

## Why This Matters
Manual data cleaning is time-consuming and error-prone. This function eliminates 80% of repetitive cleaning tasks in a single step, ensuring consistency across all data sources.

## Function Code
```m
let
    fxClean = (t as table) as table =>
        let
            // Step 1: Remove completely empty rows
            removeEmptyRows = Table.SelectRows(t,
                each not List.IsEmpty(
                    List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
                
            // Step 2: Trim whitespace from all text columns
            trimmed = Table.TransformColumns(removeEmptyRows,
                List.Transform(
                    Table.ColumnNames(removeEmptyRows),
                    (c) => {c, (x) => if x is text then Text.Trim(x) else x, type any})),
            
            // Step 3: Standardize column names (remove spaces, replace # with No)
            renamedCols = Table.TransformColumnNames(trimmed, 
                each Text.Replace(Text.Replace(_, " ", "_"), "#", "No"))
        in
            renamedCols
in
    fxClean
```

## Usage
### Basic Usage

```m
let
    source = Excel.Workbook(File.Contents("C:\data\sales.xlsx")),
    rawData = source{[Name="Sheet1"]}[Data],
    cleaned = fxClean(rawData)
in
    cleaned
```

#### What It Does

| Operation | Before | After |
|-----------|--------|-------|
| Empty Rows | Rows with all nulls/blanks | Removed entirely
| Whitespace | "  John  " | "John" |
| Column Names | "Order #", "Sales Amount"" | Order_No", "Sales_Amount" | 

## Real-World Impact
### Sales 2023 ETL Project Results
- Before: 2,000+ records with formatting issues
- After: 100% clean data in < 2 seconds
- Eliminated: ~30 minutes of manual cleaning per data refresh

### Why Each Step Matters
**1. Remove Empty Rows**
- Problem: Excel exports often include blank rows from formatting
- Impact: Prevents null-heavy datasets and incorrect aggregations
- Example: Q1 sales file had 50+ empty rows that inflated record counts

**2. Trim Whitespace**
- Problem: Leading/trailing spaces break joins and lookups
- Impact: Ensures "Poland" = "Poland" (not "Poland " or " Poland")
- Example: Customer names with hidden spaces caused 15% failed merges

**3. Standardize Column Names**
- Problem: Spaces and special characters break M code references
- Impact: Enables programmatic column access without errors
- Example: Changed "Order #" to "Order_No" for consistent scripting

## Integration with Other Functions
This function is designed to work seamlessly with the other fxLibrary functions.

#### Best Practices
**Do:**
- Apply fxClean as your first transformation step
- Use on all external data sources (Excel, CSV, databases)
- Combine with type-specific functions (fxDate, fxNumber) afterward

**Don't:**
- Apply after already cleaning data (redundant processing)
- Skip this step when data quality is critical

## Error Handling
**The function handles:**
- Mixed data types in columns (preserves non-text values)
- Null values (treats as empty)
- Single-column tables (no errors)
- Already-clean data (no changes made)
