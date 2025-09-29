# ETL Pipeline Documentation

## Overview
This document outlines the complete ETL process for transforming 8 fragmented sales data sources into a clean, relational data model.

## Pipeline Architecture

```
Raw Data (8 files) → Power Query → Cleaning Functions → Transformation → Validation → Clean Output
```

## Detailed Steps

### Phase 1: Data Ingestion
1. Import all 8 Excel files into Power Query
2. Create staging queries for each source
3. Preserve original data in separate backup

### Phase 2: Initial Cleaning (All Tables)
Applied to every data source:
- Remove completely blank rows
- Trim whitespace from all text fields  
- Remove duplicate header rows
- Standardize column names (remove spaces, special characters)

### Phase 3: Source-Specific Transformations

#### Sales Q1 & Q2 Transformation
```
1. Apply fxDate to OrderDate column
2. Apply fxCountry to Country column
3. Apply fxNumber to Quantity and UnitPrice
4. Remove duplicate OrderIDs (keep first occurrence)
5. Standardize Salesperson names with fxText
6. Merge Q1 and Q2 into unified dataset
7. Calculate SalesAmount field (Quantity × UnitPrice)
```

#### Products Transformation
```
1. Apply fxText to ProductName
2. Parse PackageSize field:
   - Extract PackCount (default: 1)
   - Extract UnitAmount and UnitType
   - Convert ml→L, g→kg
   - Create standardized format
3. Validate EAN codes (must be 13 digits)
4. Apply fxLogical to Active field
5. Remove duplicate ProductSKUs
```

#### Customers Transformation
```
1. Apply fxText to CustomerName
2. Standardize Email:
   - Convert to lowercase
   - Apply fxDiacritics for Polish characters
3. Clean Phone numbers:
   - Remove spaces, dashes, parentheses
   - Validate format
4. Apply fxCountry to Country
5. Apply fxDate to JoinDate
```

#### Returns Transformation
```
1. Apply fxDate to ReturnDate
2. Standardize ReturnReason with fxText
```

#### Targets Transformation
```
1. Unpivot months from columns to rows
2. Create Month number field
3. Standardize Salesperson names
```

#### Shipping Transformation
```
1. Split ShippingInfo by "|" delimiter:
   - Position 1 → Carrier
   - Position 2 → DeliveryType
   - Position 3 → EstimatedDays
2. Apply fxNumber to ShippingCostPLN
3. Clean ShippingAddress field
```

#### Fees Transformation
```
1. Remove duplicate combinations of Channel + Country + FeeType
2. Standardize FeeType values
3. Validate FeePercentage (0-100 range)
```

### Phase 4: Data Integration
1. Create relationships:
   - Sales.CustomerID → Customers.CustomerID
   - Sales.ProductSKU → Products.ProductSKU
2. Validate referential integrity
3. Check for orphaned records

### Phase 5: Final Validation
- Verify all dates are within 2023
- Confirm no null primary keys
- Validate all foreign key relationships
- Check numeric fields for reasonable ranges
- Ensure no duplicate primary keys

## Error Handling

### Common Issues Resolved:
1. **Mixed date formats** → fxDate function handles multiple formats
2. **Inconsistent country names** → fxCountry standardization
3. **Decimal separator issues** → fxNumber handles both . and ,
4. **Polish characters in emails** → fxDiacritics replacement
5. **Duplicate records** → Systematic deduplication by primary key

## Performance Optimization
- Load only required columns initially
- Apply filters early in transformation
- Disable query refresh for staging queries

## Maintenance Guidelines
1. Functions are reusable for future data loads
2. Document any new transformation rules
3. Maintain data quality log
4. Version control all M code

## Success Metrics
- 100% of dates successfully parsed
- 15% reduction in total records (duplicates removed)
- 0 orphaned foreign keys
- All numeric fields within valid ranges
- Processing time: < 2 minutes for full refresh
