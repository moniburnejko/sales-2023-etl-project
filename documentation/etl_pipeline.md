# ETL Pipeline Documentation

## Overview

This document outlines the complete ETL process for transforming 8 fragmented sales data sources into a clean, relational data model using Power Query and custom M functions.

### Pipeline Metrics

- **Input:** 8 Excel files with 2,000+ records
- **Output:** 7 clean tables in star schema
- **Transformations:** 50+ cleaning operations
- **Processing Time:** < 2 minutes
- **Data Quality Improvement:** 100%

## Pipeline Architecture

```
Raw Data (8 files) → Power Query → Cleaning Functions → Transformation → Validation → Clean Output
```

## Detailed Pipeline Steps

### Phase 1: Data Ingestion

#### Step 1.1: Import Data Sources
```m
let
  Source = Excel.Workbook(File.Contents("/Users/Monika/Desktop/sales_2023_database_raw.xlsx"), null, true),
  "Navigation 1" = Source{[Item = "Sales_2023_Q1", Kind = "Sheet"]}[Data],
  "Promoted headers" = Table.PromoteHeaders(#"Navigation 1", [PromoteAllScalars = true])
in
  "Promoted headers"
```

#### Step 1.2: Create Staging Queries
- Create separate query for each data source
- Disable automatic type detection
- Preserve original data structure
- Create backup copies

#### Step 1.3: Initial Assessment

| Source | Rows | Columns | Issues Found |
|--------|------|---------|--------------|
| Sales Q1 | 400 | 12 | Duplicates, mixed dates |
| Sales Q2 | 450 | 12 | Column mismatch |
| Products | 100 | 9 | Package format chaos |
| Customers | 200 | 9 | Email/phone issues |
| Returns | 50 | 5 | Date format issues |
| Fees | 20 | 4 | Duplicates |
| Shipping | 200 | 4 | Composite field |
| Targets_Wide | 7 | 8 | Wide format |

### Phase 2: Initial Cleaning

Applied to **ALL** data sources:

```m
let
    fxClean = (t as table) as table =>
        let
            removeEmptyRows = Table.SelectRows(t,
                each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
                
            trimmed = Table.TransformColumns(removeEmptyRows,
                List.Transform(Table.ColumnNames(removeEmptyRows),
                    (c) => {c, (x) => if x is text then Text.Trim(x) else x, type any})),

            renamedCols = Table.TransformColumnNames(trimmed, each Text.Replace(Text.Replace(_, " ", "_"), "#", "No"))
        in
            renamedCols
in
    fxClean
```

### Phase 3: Custom Function Library

#### 3.1: fxDate - Universal Date-Time Parser
```m
let
    fxDate = (x as any) as nullable date =>
    let
        directResult =
            if Value.Is(x, type date) then x
            else if Value.Is(x, type datetime) then Date.From(x)
            else null,

        result =
            if directResult <> null then directResult
            else if x = null then null
            else
                let
                    cleanText = Text.Trim(Text.From(x)),
                    normalized = Text.Replace(Text.Replace(cleanText, ".", "-"), "/", "-"),

                    attempt1dt = try DateTime.FromText(cleanText) otherwise null,
                    attempt2dt = if attempt1dt = null then try DateTime.FromText(normalized) otherwise null else attempt1dt,
                    attempt1dtz = if attempt2dt = null then try DateTimeZone.FromText(cleanText) otherwise null else null,
                    attempt2dtz = if attempt2dt = null and attempt1dtz = null then try DateTimeZone.FromText(normalized) otherwise null else attempt1dtz,

                    fromDatetime =
                        if attempt1dt <> null then Date.From(attempt2dt)
                        else if attempt2dt <> null then Date.From(dtAttempt2)
                        else if attempt1dtz <> null then Date.From(attempt1dtz)
                        else if attempt2dtz <> null then Date.From(attempt2dtz)
                        else null,

                    attempt1 = if fromDatetime = null then try Date.FromText(cleanText, "en-US") otherwise null else fromDatetime,
                    attempt2 = if attempt1 = null then try Date.FromText(cleanText, "en-GB") otherwise null else attempt1,
                    attempt3 = if attempt2 = null then try Date.FromText(cleanText, "pl-PL") otherwise null else attempt2,
                    attempt4 = if attempt3 = null then try Date.FromText(normalized, "en-GB") otherwise null else attempt3,
                    attempt5 = if attempt4 = null then try Date.FromText(normalized, "pl-PL") otherwise null else attempt4,
                    attempt6 = if attempt5 = null then try Date.FromText(normalized, "en-US") otherwise null else attempt5

                in
                    if fromDatetime <> null then fromDatetime
                    else if attempt1 <> null then attempt1
                    else if attempt2 <> null then attempt2
                    else if attempt3 <> null then attempt3
                    else if attempt4 <> null then attempt4
                    else if attempt5 <> null then attempt5
                    else attempt6
    in
        result
in
    fxDate
```

#### 3.2: fxNumber - Numeric Standardization
```m
let
    fxNumber = (numberValue as any) as number =>
    let
        result =
            if numberValue is number then numberValue
            else if numberValue is text then
                let
                    standardized = Text.Replace(numberValue, ",", "."),
                    cleaned = Text.Select(standardized, {"0".."9", ".", "-"}),
                    parsed = try Number.From(cleaned) otherwise null
                in
                    parsed
            else null
    in
        result
in
    fxNumber
```

#### 3.3: fxCountry - Country Name Standardization
```m
let
    fxCountry = (countryValue as text) as text =>
    let
        countryMap = [
            poland = "Poland", polska = "Poland", republic of poland = "Poland", pl = "Poland",
            germany = "Germany", deutschland = "Germany", de = "Germany",
            france = "France", fr = "France",
            czechia = "Czechia", czech republic = "Czechia", cz = "Czechia",
            lithuania = "Lithuania", lt = "Lithuania"
        ],
        lower = Text.Lower(Text.Trim(countryValue)),
        standardized = Record.FieldOrDefault(countryMap, lower, Text.Proper(countryValue))
    in
        standardized
in
    fxCountry
```

#### 3.4: fxText - Text cleaning & normalization
```m
let
    fxText = (txt as text) as text =>
    let
        allowed = 
            {"A".."Z","a".."z","0".."9"," ", "."} & 
            {"Ą","Ć","Ę","Ł","Ń","Ó","Ś","Ź","Ż","ą","ć","ę","ł","ń","ó","ś","ź","ż"},
        
        toList = Text.ToList(txt),
        filtered = List.Select(toList, each List.Contains(allowed,_)),
        cleaned = Text.Combine(filtered,""),
        singleSpace = Text.Trim(Text.Replace(cleaned, "  ", " ")),
        result = Text.Proper(singleSpace)
    in
        result
in
    fxText
```

#### 3.5: fxDiacritics - Diacritic Normalization
```m
let
fxDiacritics = (x as nullable text) as nullable text =>
  let
      t = if x=null then null else x,
     pairs = {
         {"ą","a"}, {"ć","c"}, {"ę","e"}, {"ł","l"}, {"ń","n"}, {"ó","o"}, {"ś","s"}, {"ż","z"}, {"ź","z"},
          {"Ą","A"}, {"Ć","C"}, {"Ę","E"}, {"Ł","L"}, {"Ń","N"}, {"Ó","O"}, {"Ś","S"}, {"Ż","Z"}, {"Ź","Z"}
     },
     result = if t=null then null else
            List.Accumulate(pairs, t, (state, p) => Text.Replace(state, p{0}, p{1}))
  in
     result
in
  fxDiacritics
```

#### 3.6: fxLogical - Text-to-Logical Standardization
```m
let
  fxLogical = (x as nullable any) as nullable logical =>
  let
     txt = if x=null then null else Text.Upper(Text.From(x)),
      result =
         if txt=null then null
         else if txt="YES" or txt="Y" or txt="TRUE" or txt="1" then true
         else if txt="NO" or txt="N" or txt="FALSE" or txt="0" then false
         else null
  in
      result
in fxLogical
```

### Phase 4: Source-Specific Transformations

#### 4.1: Sales Q1 & Q2 Transformation

##### Sales Q2
```m
let
  source = fxClean(Sales_2023_Q2),
  
  // Step 1: Rename columns
  renamedCols = Table.RenameColumns(source, {{"Order_ID", "OrderID"}, {"Date", "OrderDate"}, {"CustID", "CustomerID"}, {"SKU", "ProductSKU"}, {"Quantity", "Qty"}, {"Price", "UnitPrice"}, {"Curr", "Currency"}, {"Country_Name", "Country"},  {"Rep", "Salesperson"}}),
  
  // Step 2: Apply date standardization
  standardizeDates = Table.TransformColumns(renamedCols, {{"OrderDate", each fxDate(_)}}),
  
  // Step 3: Standardize country names
  standardizeCountries = Table.TransformColumns(standardizeDates, {"Country", each fxCountry(_)}),

  // Step 4: Validate numbers
  validateNumbers = Table.TransformColumns(standardizeCountries, {{"Qty", each fxNumber(_), type number}, {"UnitPrice", each fxNumber(_), type number}}),

  // Step 5: Change column type
  changeType = Table.TransformColumnTypes(validateNumbers, {{"OrderID", type text}, {"OrderDate", type date}, {"CustomerID", type text}, {"ProductSKU", type text}, {"Qty", Int64.Type}, {"Currency", type text}, {"Country", type text}, {"City", type text}, {"Salesperson", type text}, {"Channel", type text}}),
  
  // Step 4: Remove duplicates
  removeDuplicates = Table.Distinct(changeType, {"OrderID"})
  
in
  removeDuplicates
```

##### Sales Q1
```m
let
  source = fxClean(Sales_2023_Q1),

  // Step 1: Apply date standardization
  standardizeDates = Table.TransformColumns(source, {{"OrderDate", each fxDate(_)}}),
  
  // Step 2: Standardize country names
  standardizeCountries = Table.TransformColumns(standardizeDates, {"Country", each fxCountry(_)}),

  // Step 3: Validate numbers
  validateNumbers = Table.TransformColumns(standardizeCountries, {{"Qty", each fxNumber(_), type number}, {"UnitPrice", each fxNumber(_), type number}}),

  // Step 4: Change column type
  changeType = Table.TransformColumnTypes(validateNumbers, {{"OrderID", type text}, {"OrderDate", type date}, {"CustomerID", type text}, {"ProductSKU", type text}, {"Qty", Int64.Type}, {"Currency", type text}, {"Country", type text}, {"City", type text}, {"Salesperson", type text}, {"Channel", type text}}),
  
  // Step 4: Remove duplicates
  removeDuplicates = Table.Distinct(changeType, {"OrderID"}),
  
  // Step 5: Append Q1 and Q2
  appendQuery = Table.Combine({removeDuplicates, Sales_Q2}),

  // Step 6: Calculate SalesAmount
  addSalesAmount = Table.AddColumn(appendQuery, "SalesAmount",
        each [Qty] * [UnitPrice], type number),

  // Step 7: Change column order 
  changeOrder = Table.ReorderColumns(addSalesAmount, {"OrderID", "OrderDate", "CustomerID", "ProductSKU", "Qty", "UnitPrice", "SalesAmount", "Currency", "Country", "City", "Salesperson", "Channel"})

in
    changeOrder
```

Results: 850 clean transaction records

### 4.2: Products Transformation
```m
let
    Source = fxClean(Products),

  // Step 1: Rename columns
    RenamedColumns = Table.RenameColumns(Source, {{"SKU", "ProductSKU"}}),

  // Step 2: Standardize text columns
  #"Replaced value" = Table.ReplaceValue(RenamedColumns, "1", "i", Replacer.ReplaceText, {"ProductName"}),
    
    StandardizeText = Table.TransformColumns(
        #"Replaced value", 
        {
            {"ProductName", each fxText(_), type text}, 
            {"Category", each fxText(_), type text}, 
            {"Subcategory", each fxText(_), type text}
        }
    ),
  // Step 3: Validate numbers
    ValidateNumbers = Table.TransformColumns(
        StandardizeText, 
        {{"UnitCost", each fxNumber(_), type number}}
    ),

  // Step 4: Logical normalization     
    LogicalColumn = Table.TransformColumns(
        ValidateNumbers, 
        {{"Active", each fxLogical(_), type logical}}
    ),
  // Step 5: Complex package size normalization
    PackageSizeClean = (packageSizeValue) => 
        let
            // Step 5.1: Clean and normalize input text
            txt = 
                if packageSizeValue = null then 
                    null 
                else 
                    Text.Trim(
                        Text.Replace(
                            Text.Replace(
                                Text.Replace(
                                    Text.From(packageSizeValue),
                                    "×", "x"
                                ),
                                "X", "x"
                            ),
                            "  ", " "
                        )
                    ),
            
            // Step 5.2: Split by delimiter and determine format
            parts = if txt = null then {} else Text.Split(txt, "x"),
            hasDelim = List.Count(parts) > 1,
            p1 = try Text.Trim(parts{0}) otherwise null,
            p2 = if hasDelim then try Text.Trim(parts{1}) otherwise null else null,
            
            // Step 5.3: Extract pack count (e.g., "6" from "6x330ml")
            packCount = 
                if hasDelim then 
                    let 
                        digits = Text.Select(p1, {"0".."9"}) 
                    in 
                        if digits = "" then 1 else Number.From(digits)
                else 
                    1,
            
            // Step 5.4: Identify unit candidate (value + unit)
            unitCandidate = if hasDelim then p2 else p1,
            u0 = if unitCandidate = null then null else Text.Replace(unitCandidate, " ", ""),
            
            // Step 5.5: Separate numeric value and unit symbol
            rawNum = if u0 = null then "" else Text.Select(u0, {"0".."9", ".", ","}),
            rawLet = if u0 = null then "" else Text.Select(u0, {"A".."Z", "a".."z"}),
            
            // Step 5.6: Normalize unit symbol (ml→L, g→kg, etc.)
            unitSymbol = 
                let 
                    lower = Text.Lower(rawLet) 
                in 
                    if lower = "l" then "L" else lower,
            
            unitNumber = 
                if rawNum = "" then 
                    null 
                else 
                    try Number.From(Text.Replace(rawNum, ",", ".")) otherwise null,
            
            // Step 5.7: Convert units (ml→L, g→kg)
            convertedNumber = 
                if unitSymbol = "ml" then 
                    if unitNumber = null then null else unitNumber / 1000
                else if unitSymbol = "g" then 
                    if unitNumber = null then null else unitNumber / 1000
                else 
                    unitNumber,
            
            convertedSymbol = 
                if unitSymbol = "ml" then "L"
                else if unitSymbol = "g" then "kg"
                else unitSymbol,
            
            // Step 5.8: Format final number with 2 decimal places
            convertedNumberText = 
                if convertedNumber = null then 
                    "" 
                else 
                    Number.ToText(convertedNumber, "0.##", "en-US"),
            
            // Step 5.9: Build final standardized output
            result =
                if convertedNumberText = "" and (convertedSymbol = null or convertedSymbol = "") then

                    // Case: No unit info (e.g., "6" → "6")
                    Text.From(packCount)
                else if convertedNumberText <> "" and convertedSymbol <> "" then
                    // Case: Full info (e.g., "6x330ml" → "6 × 0.33 L")
                    Text.From(packCount) & " × " & convertedNumberText & " " & convertedSymbol
                else if convertedNumberText <> "" then
                    // Case: Number only (e.g., "6x330" → "6 × 330")
                    Text.From(packCount) & " × " & convertedNumberText
                else
                    // Case: Unit only (e.g., "6xL" → "6 × L")
                    Text.From(packCount) & " × " & convertedSymbol
        in
            result,
    
  // Step 6: Apply the PackageSize transformation
    TransformPackageSize = Table.TransformColumns(
        LogicalColumn,
        {{"PackageSize", each PackageSizeClean(_), type text}}
    ),

  // Step 7: Validate EAN codes
    ValidateEAN = Table.SelectRows(TransformPackageSize, each Text.Length([EAN]) = 13),

  // Step 8: Remove duplicates
  RemoveDuplicates = Table.Distinct(ValidateEAN, {"ProductSKU"}),

  // Step 9: Change column type
  ChangeType = Table.TransformColumnTypes(RemoveDuplicates, {{"ProductSKU", type text}, {"Supplier", type text}, {"EAN", Int64.Type}})
in
    ChangeType
```

Results: 60 products with normalized package sizes

### 4.3: Customers Transformation
```m
let
    Source = fxClean(Customers),
    
    // Step 1: Standardize text columns
    StandardizeText = Table.TransformColumns(
        Source,
        {
            {"CustomerName", each fxText(_), type text},
            {"Segment", each fxText(_), type text}
        }
    ),
    
    // Step 2: Email normalization with diacritics removal
    NormalizeEmails = Table.TransformColumns(
        StandardizeText, 
        {
            {"Email", each 
                let
                    Lower = Text.Lower(_),
                    NoDiacritics = fxDiacritics(Lower)
                in
                    NoDiacritics, 
                type text
            }
        }
    ),
    
    // Step 3: Phone standardization
    StandardizePhones = Table.TransformColumns(
        NormalizeEmails, 
        {
            {"Phone", each Text.Select(_, {"0".."9", "+"}), type text}
        }
    ),
    
    // Step 4: Standardize country names
    StandardizeCountries = Table.TransformColumns(
        StandardizePhones, 
        {{"Country", each fxCountry(_), type text}}
    ),
    
    // Step 5: Apply date standardization
    StandardizeDates = Table.TransformColumns(
        StandardizeCountries, 
        {{"JoinDate", each fxDate(_), type date}}
    ),

    // Step 6: Remove duplicates
    RemoveDuplicates = Table.Distinct(StandardizeDates, {"CustomerID"}),

    // Step 7: Change column types
    ChangeType = Table.TransformColumnTypes(RemoveDuplicates, {{"CustomerID", type text}, {"City", type text}, {"VAT", type text}})
in
    ChangeType

```

Results: 120 customers with clean contact data

## Phase 5: Data Integration
### 5.1: Create Relationships
```m
let  
  // Step 1: Merge with Products
  mergedWithProducts = Table.NestedJoin(
    changeOrder, {"ProductSKU"},
    Products, {"ProductSKU"},
    "ProductDetails", JoinKind.LeftOuter),

  // Step 2: Expand Products columns
  expandedProducts = Table.ExpandTableColumn(
    mergedWithProducts, "ProductDetails",
    {"ProductName", "Category", "Subcategory", "UnitCost"},
    {"ProductName", "Category", "Subcategory", "UnitCost"}),
  
  // Step 3: Merge with Customers
  mergedWithCustomers = Table.NestedJoin(
    expandedProducts, {"CustomerID"},
    Customers, {"CustomerID"},
    "Customers", JoinKind.LeftOuter),

  // Step 4: Expand Customers columns
  expandedCustomers = Table.ExpandTableColumn(
    mergedWithCustomers, "Customers",
    {"CustomerName", "Email", "Phone", "Country", "City", "Segment"},
    {"CustomerName", "Email", "Phone", "CustomerCountry", "CustomerCity", "Segment"}),

  // Step 5: Rename columns
  renamedCols = Table.RenameColumns(expandedCustomers, {{"Country", "OrderCountry"}, {"City", "OrderCity"}}),

  // Step 6: Change column order
  reorderedCols = Table.ReorderColumns(renamedCols, {"OrderID", "OrderDate", "CustomerID", "CustomerName", "Email", "Phone", "CustomerCountry", "CustomerCity", "Segment", "ProductSKU", "ProductName", "Category", "Subcategory", "UnitCost", "Qty", "UnitPrice", "SalesAmount", "Currency", "OrderCountry", "OrderCity", "Salesperson", "Channel"})
in 
  reorderedCols
```

### 5.2: Validate Referential Integrity

## Phase 6: Final Validation
### Validation Checklist

## Error Handling
### Common Issues & Solutions

## Performance Optimization

## Maintenance Guidelines

## Success Metrics

## Future Enhancements

## Error Handling


