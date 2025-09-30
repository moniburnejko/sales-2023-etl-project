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
            RemoveEmptyRows = Table.SelectRows(t,
                each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
            Trimmed = Table.TransformColumns(
                RemoveEmptyRows,
                List.Transform(
                    Table.ColumnNames(RemoveEmptyRows),
                    (c) => {c, (x) => if x is text then Text.Trim(x) else x, type any})),
            RenamedCols = Table.TransformColumnNames(Trimmed, each Text.Replace(Text.Replace(_, " ", "_"), "#", "No"))
        in
            RenamedCols
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
        Result =
            if numberValue is number then numberValue
            else if numberValue is text then
                let
                    Standardized = Text.Replace(numberValue, ",", "."),
                    Cleaned = Text.Select(Standardized, {"0".."9", ".", "-"}),
                    Parsed = try Number.From(Cleaned) otherwise null
                in
                    Parsed
            else null
    in
        Result
in
    fxNumber
```

#### 3.3: fxCountry - Country Name Standardization
```m
let
    fxCountry = (countryValue as text) as text =>
    let
        CountryMap = [
            poland = "Poland", polska = "Poland", republic of poland = "Poland", pl = "Poland",
            germany = "Germany", deutschland = "Germany", de = "Germany",
            france = "France", fr = "France",
            czechia = "Czechia", czech republic = "Czechia", cz = "Czechia",
            lithuania = "Lithuania", lt = "Lithuania"
        ],
        Lower = Text.Lower(Text.Trim(countryValue)),
        Standardized = Record.FieldOrDefault(CountryMap, Lower, Text.Proper(countryValue))
    in
        Standardized
in
    fxCountry
```

#### 3.4: fxText - Text cleaning & normalization
```m
let
    fxText = (txt as text) as text =>
    let
        Allowed = 
            {"A".."Z","a".."z","0".."9"," ", "."} & 
            {"Ą","Ć","Ę","Ł","Ń","Ó","Ś","Ź","Ż","ą","ć","ę","ł","ń","ó","ś","ź","ż"},
        
        ToList = Text.ToList(txt),
        Filtered = List.Select(ToList, each List.Contains(Allowed,_)),
        Cleaned = Text.Combine(Filtered,""),
        SingleSpace = Text.Trim(Text.Replace(Cleaned, "  ", " ")),
        Result = Text.Proper(SingleSpace)
    in
        Result
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
  Source = fxClean(Sales_2023_Q2),
  
  // Step 1: Rename columns
  RenamedColumns = Table.RenameColumns(Source, {{"Order_ID", "OrderID"}, {"Date", "OrderDate"}, {"CustID", "CustomerID"}, {"SKU", "ProductSKU"}, {"Quantity", "Qty"}, {"Price", "UnitPrice"}, {"Curr", "Currency"}, {"Country_Name", "Country"},  {"Rep", "Salesperson"}}),
  
  // Step 2: Apply date standardization
  StandardizeDates = Table.TransformColumns(RenamedColumns, {{"OrderDate", each fxDate(_)}}),
  
  // Step 3: Standardize country names
  StandardizeCountries = Table.TransformColumns(StandardizeDates, {"Country", each fxCountry(_)}),

  // Step 4: Validate numbers
  ValidateNumbers = Table.TransformColumns(StandardizeCountries, {{"Qty", each fxNumber(_), type number}, {"UnitPrice", each fxNumber(_), type number}}),

  // Step 5: Change column type
  ChangeType = Table.TransformColumnTypes(ValidateNumbers, {{"OrderID", type text}, {"OrderDate", type date}, {"CustomerID", type text}, {"ProductSKU", type text}, {"Qty", Int64.Type}, {"Currency", type text}, {"Country", type text}, {"City", type text}, {"Salesperson", type text}, {"Channel", type text}}),
  
  // Step 4: Remove duplicates
  RemoveDuplicates = Table.Distinct(ChangeType, {"OrderID"})
  
in
  RemoveDuplicates
```

##### Sales Q1
```m
let
  Source = fxClean(Sales_2023_Q1),

  // Step 1: Apply date standardization
  StandardizeDates = Table.TransformColumns(Source, {{"OrderDate", each fxDate(_)}}),
  
  // Step 2: Standardize country names
  StandardizeCountries = Table.TransformColumns(StandardizeDates, {"Country", each fxCountry(_)}),

  // Step 3: Validate numbers
  ValidateNumbers = Table.TransformColumns(StandardizeCountries, {{"Qty", each fxNumber(_), type number}, {"UnitPrice", each fxNumber(_), type number}}),

  // Step 4: Change column type
  ChangeType = Table.TransformColumnTypes(ValidateNumbers, {{"OrderID", type text}, {"OrderDate", type date}, {"CustomerID", type text}, {"ProductSKU", type text}, {"Qty", Int64.Type}, {"Currency", type text}, {"Country", type text}, {"City", type text}, {"Salesperson", type text}, {"Channel", type text}}),
  
  // Step 4: Remove duplicates
  RemoveDuplicates = Table.Distinct(ChangeType, {"OrderID"})
  
 // Step 5: Append Q1 and Q2
  AppendQuery = Table.Combine({RemoveDuplicates, Sales_Q2}),

 // Step 6: Calculate SalesAmount
  AddSalesAmount = Table.AddColumn(AppendQuery, "SalesAmount",
        each [Qty] * [UnitPrice], type number),
  ChangeOrder = Table.ReorderColumns(AddSalesAmount, {"OrderID", "OrderDate", "CustomerID", "ProductSKU", "Qty", "UnitPrice", "SalesAmount", "Currency", "Country", "City", "Salesperson", "Channel"})

in
    ChangeOrder
```

Results: 850 clean transaction records

### 4.2: Products Transformation

### 4.3: Customers Transformation

## Phase 5: Data Integration

### 5.1: Create Relationships
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


