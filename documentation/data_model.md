# Data Model Documentation

## Overview

This data model follows a **star schema** design with **Sales_2023** as the central fact table, enriched with product and customer attributes through denormalization for analytical efficiency. The model includes:

- **1 Fact Table**: Sales_2023 (850 records)
- **2 Dimension Tables**: Products, Customers
- **4 Supporting Tables**: Returns, Fees, Shipping, Targets
  
**Model Type**: Hybrid Star Schema with denormalized fact table for optimized querying.

## Table Structures

### FACT TABLE

#### **Sales_2023** (850 records)
Central fact table containing all sales transactions with denormalized customer and product attributes.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| **OrderID** | Text (PK) | Unique order identifier | O312146 |
| **OrderDate** | Date | Transaction date | 2023-03-29 |
| **CustomerID** | Text (FK) | Customer identifier | C1112 |
| **CustomerName** | Text | Customer full name (denormalized) | Kasia Mazur |
| **Email** | Text | Customer email (denormalized) | kasia.mazur@mail.com |
| **Phone** | Text | Customer phone (denormalized) | +420623497528 |
| **CustomerCountry** | Text | Customer's country (denormalized) | Poland |
| **CustomerCity** | Text | Customer's city (denormalized) | Gdańsk |
| **Segment** | Text | Customer segment (denormalized) | VIP |
| **ProductSKU** | Text (FK) | Product identifier | P3091-A |
| **ProductName** | Text | Product name (denormalized) | Laundry Liquid |
| **Category** | Text | Product category (denormalized) | Household |
| **Subcategory** | Text | Product subcategory (denormalized) | Paper |
| **UnitCost** | Decimal | Product unit cost (denormalized) | 3.30 |
| **Qty** | Integer | Quantity sold | 5 |
| **UnitPrice** | Decimal | Selling price per unit | 175.26 |
| **SalesAmount** | Decimal | Calculated: Qty × UnitPrice | 876.30 |
| **Currency** | Text | Original transaction currency | PLN |
| **OrderCountry** | Text | Delivery country | Latvia |
| **OrderCity** | Text | Delivery city | Riga |
| **Salesperson** | Text | Sales representative | E. Dabrowska |
| **Channel** | Text | Sales channel | Wholesale |

**Key Features:**
- Primary Key: OrderID
- Foreign Keys: CustomerID, ProductSKU
- Calculated Field: SalesAmount (Qty × UnitPrice)
- Denormalized for query performance

### DIMENSION TABLES

#### **Products** (60 records)
Product master data with specifications and attributes.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| **ProductSKU** | Text (PK) | Unique product identifier | P2824-A |
| **ProductName** | Text | Product name | Bbq Chips |
| **Category** | Text | Main product category | Beverages |
| **Subcategory** | Text | Product subcategory | Coffee |
| **UnitCost** | Decimal | Cost per unit | 34.48 |
| **Active** | Boolean | Product availability status | false |
| **Supplier** | Text | Supplier name | Baltic Co. |
| **PackageSize** | Text | Standardized package format | 1 × 1 kg |
| **EAN** | Text | European Article Number (barcode) | 130201276659 |

**Key Features:**
- Primary Key: ProductSKU
- Referenced by Sales_2023
- Contains standardized PackageSize (result of normalization)

#### **Customers** (120 records)
Customer master data with contact information and segmentation.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| **CustomerID** | Text (PK) | Unique customer identifier | C1000 |
| **CustomerName** | Text | Full customer name | Ola Lewandowski |
| **Email** | Text | Email address (normalized) | ola.lewandowski@firma.pl |
| **Phone** | Text | Phone number (standardized) | +491773955087 |
| **Country** | Text | Customer country | Lithuania |
| **City** | Text | Customer city | Vilnius |
| **Segment** | Text | Customer segment | VIP |
| **JoinDate** | Date | Customer registration date | 2023-03-19 |
| **VAT** | Text | VAT/Tax number | (varies) |

**Key Features:**
- Primary Key: CustomerID
- Referenced by Sales_2023
- Email normalized (lowercase, ASCII)
- Phone standardized (removed formatting)

### SUPPORTING TABLES

#### **Returns** (40 records)
Post-sale return transactions linked to orders.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| **ReturnID** | Text (PK) | Unique return identifier | R10000 |
| **OrderID** | Text (FK) | Reference to original order | O500099 |
| **Reason** | Text | Return reason category | Other |
| **Date** | Date | Return processing date | 2023-05-21 |
| **Status** | Text | Current return status | Pending |

**Relationship**: One-to-Many with Sales_2023 (1 order can have multiple returns)

#### **Fees** (6 records)
Fee structure for sales channels (Poland market only).

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| **Channel** | Text | Sales channel | Online |
| **Country** | Text | Market (always Poland) | Poland |
| **FeeType** | Text | Fee calculation type | % |
| **FeeValue** | Decimal | Fee amount or percentage | 2.5 |

**Relationship**: Many-to-One with Sales_2023 (via Channel + Country)  
**Coverage**: Poland only

#### **Shipping** (200 records)
Shipping details for delivered orders (Poland market only).

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| **OrderID** | Text (FK) | Reference to order | O881975 |
| **Carrier** | Text | Shipping provider | DHL |
| **DeliveryType** | Text | Service level | Express |
| **EstimatedDelivery** | Text | Delivery timeframe | 2-4d |
| **ShippingCostPLN** | Decimal | Shipping cost in PLN | 25.49 |
| **Address** | Text | Delivery address | al. Piłsudskiego 12/5, 90-368 Łódź |

**Relationship**: One-to-One with Sales_2023 (via OrderID)  
**Coverage**: Poland only (~200 out of 850 orders)

#### **Targets** (42 records)
Monthly sales targets by salesperson.

| Column | Data Type | Description | Example |
|--------|-----------|-------------|---------|
| **Salesperson** | Text | Sales representative name | A. Zielińska |
| **Month** | Text | Month name | Jan |
| **MonthNumber** | Integer | Numeric month (1-12) | 1 |
| **Target** | Decimal | Monthly sales target | 58637 |
| **Note** | Text | Additional notes | (optional) |

**Relationship**: Many-to-One with Sales_2023 (via Salesperson + Month)  
**Purpose**: Enables actual vs target performance analysis

### Relationship Details

| From Table | To Table | Type | Key Fields | Cardinality |
|------------|----------|------|------------|-------------|
| Products | Sales_2023 | Dimension | ProductSKU | 1:many |
| Customers | Sales_2023 | Dimension | CustomerID | 1:many |
| Sales_2023 | Returns | Fact to Support | OrderID | 1:many |
| Sales_2023 | Fees | Fact to Support | Channel + Country | many:1 |
| Sales_2023 | Shipping | Fact to Support | OrderID | 1:1 |
| Sales_2023 | Targets | Fact to Support | Salesperson + Month | many:1 |

## Design Decisions

### Why Denormalize the Fact Table?

**Sales_2023** includes customer and product attributes directly rather than only storing IDs.

**Benefits:**
- **Query Performance**: Eliminates joins for common analytical queries
- **Ease of Use**: Analysts can query fact table directly
- **Reduced Complexity**: Simpler queries for reporting tools

**Trade-offs:**
- **Storage**: Slightly larger table size (acceptable for 850 records)
- **Updates**: Changes to customer/product data require fact table updates
- **Solution**: Maintains Products/Customers as source of truth for master data management

### Why Keep Supporting Tables Separate?

#### **Returns** (Separate)
- Post-sale events; most orders have no returns
- Separate table avoids NULL values in 96% of transactions
- Maintains clean separation between transaction and post-sale processes

#### **Fees & Shipping** (Poland Only)
- Limited to single market (Poland)
- ~200 of 850 orders (~24%)
- Merging would create NULL values for 76% of records
- Separate tables preserve scalability for future market expansion

#### **Targets** (Separate)
- Planned targets vs actual transactions (different data types)
- Monthly granularity vs daily transactions
- Separation enables clean actual vs target comparison queries

## Data Quality Achievements

| Quality Metric | Result |
|----------------|--------|
| **Duplicate Records** | 0 (100% eliminated) |
| **Standardized Formats** | 100% (dates, numbers, text) |
| **Valid Join Keys** | 100% (all foreign keys validated) |
| **NULL Values** | Minimized through design |
| **Referential Integrity** | Maintained across all relationships |

## Key Transformations Applied

### Sales_2023 Consolidation
- Merged Sales_2023_Q1 and Sales_2023_Q2 (400 + 450 = 850 records)
- Standardized date formats across quarters
- Unified column naming conventions
- Calculated SalesAmount field
- Merged with Products and Customers for denormalization

### Products
- Normalized PackageSize (6x330ml → 6 × 0,33 L)
- Standardized product names
- Validated EAN codes (13 digits)
- Removed duplicate ProductSKUs

### Customers
- Email normalization (lowercase, ASCII conversion)
- Phone standardization (+48 123-456-789 → +48123456789)
- Country name standardization
- Deduplicated by CustomerID

### Returns
- Standardized Reason categories
- Converted Date to proper Date type

### Fees
- Deduplicated by Channel + Country + FeeType

### Shipping
- Split composite ShippingInfo field (if applicable)
- Standardized Carrier and DeliveryType values

### Targets
- Already in long format (Salesperson, Month, Target)
- Added MonthNumber for easier date joins

## Model Scalability

### Future Enhancements
- Add additional markets to Fees and Shipping tables
- Add Q3/Q4 data to Sales_2023 for full-year analysis
- Create calculated fields for profit margins
- Add time dimension table for advanced date analysis

### Maintenance Considerations
- Periodic refresh of Products and Customers master data
- Monthly updates to Targets
- Regular validation of referential integrity

## Technical Specifications

**Data Model Type**: Hybrid Star Schema  
**Total Tables**: 7  
**Total Records**: ~1.5K  
**Primary Keys**: Validated and unique  
**Foreign Keys**: Referential integrity maintained  
**Calculated Fields**: SalesAmount, MonthNumber  

**Tools Used**: Power Query (Excel/Power BI)  
**ETL Process**: Extract → Transform → Load → Validate  
**Documentation Date**: September 2025
