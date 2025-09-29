# Data Dictionary
## Sales 2023 ETL Project

---

## Overview

This data dictionary provides comprehensive documentation of all tables, fields, data types, and business rules in the Sales 2023 dataset. The data follows a star schema design with Sales_2023 as the central fact table.

**Last Updated:** September 2025  
**Total Tables:** 7 
**Total Records:** ~1.5K 

---

## Table: Sales_2023 (Fact Table)

**Description:** Central fact table containing all sales transactions with denormalized customer and product attributes for query performance.

**Record Count:** 850  
**Grain:** One row per order line item  
**Primary Key:** OrderID  

| Column Name | Data Type | Nullable | Description | Example Value | Business Rules |
|-------------|-----------|----------|-------------|---------------|----------------|
| OrderID | Text | No | Unique order identifier | O312146 | Primary Key; Format: O######; Must be unique |
| OrderDate | Date | No | Transaction date | 2023-03-29 | Valid date in 2023; Used for time-based analysis |
| CustomerID | Text | No | Customer identifier | C1112 | Foreign Key to Customers; Format: C#### |
| CustomerName | Text | No | Customer full name (denormalized) | Kasia Mazur | Proper case; From Customers table |
| Email | Text | No | Customer email (denormalized) | kasia.mazur@mail.com | Lowercase; ASCII only; From Customers |
| Phone | Text | No | Customer phone (denormalized) | +420623497528 | Standardized format; No spaces/dashes |
| CustomerCountry | Text | No | Customer's country (denormalized) | Poland | Standardized country name |
| CustomerCity | Text | No | Customer's city (denormalized) | Gdańsk | Proper case |
| Segment | Text | No | Customer segment (denormalized) | VIP | Values: VIP, Regular, New |
| ProductSKU | Text | No | Product identifier | P3091-A | Foreign Key to Products; Format: P####-A |
| ProductName | Text | No | Product name (denormalized) | Laundry Liquid | Proper case; From Products table |
| Category | Text | No | Product category (denormalized) | Household | Standardized category name |
| Subcategory | Text | No | Product subcategory (denormalized) | Paper | Standardized subcategory |
| UnitCost | Decimal | No | Product unit cost (denormalized) | 3.30 | Cost in PLN; Always positive |
| Qty | Integer | No | Quantity sold | 5 | Must be > 0 |
| UnitPrice | Decimal | No | Selling price per unit | 175.26 | Price in original currency |
| SalesAmount | Decimal | No | Calculated transaction value | 876.30 | Qty × UnitPrice; Original currency |
| Currency | Text | No | Original transaction currency | PLN | ISO codes: PLN, EUR, USD |
| OrderCountry | Text | No | Delivery country | Latvia | May differ from CustomerCountry |
| OrderCity | Text | No | Delivery city | Riga | May differ from CustomerCity |
| Salesperson | Text | No | Sales representative | E. Dabrowska | Format: FirstInitial. LastName |
| Channel | Text | No | Sales channel | Wholesale | Values: Wholesale, Online, Retail |

**Notes:**
- SalesAmount is calculated field (not stored in source)
- Customer and Product attributes denormalized for performance
- OrderCountry/City may differ from Customer location (ship-to address)

---

## Table: Products (Dimension)

**Description:** Product master data with specifications and attributes.

**Record Count:** 60  
**Grain:** One row per product  
**Primary Key:** ProductSKU  

| Column Name | Data Type | Nullable | Description | Example Value | Business Rules |
|-------------|-----------|----------|-------------|---------------|----------------|
| ProductSKU | Text | No | Unique product identifier | P2824-A | Primary Key; Format: P####-A |
| ProductName | Text | No | Product name | Bbq Chips | Proper case; Standardized spelling |
| Category | Text | No | Main product category | Beverages | Standardized; ~10 categories |
| Subcategory | Text | No | Product subcategory | Coffee | Standardized; ~30 subcategories |
| UnitCost | Decimal | No | Cost per unit | 34.48 | Always in PLN; Must be > 0 |
| Active | Boolean | No | Product availability status | false | true = available; false = discontinued |
| Supplier | Text | Yes | Supplier name | Baltic Co. | Proper case; Can be null |
| PackageSize | Text | No | Standardized package format | 1 × 1 kg | Format: Count × Value Unit; Normalized |
| EAN | Text | No | European Article Number | 130201276659 | Barcode; 13 digits; Validated |

**Notes:**
- PackageSize normalized from various formats (6x330ml → 6 × 0,33 L)
- All units converted to base forms (ml→L, g→kg)
- EAN codes validated for 13-digit length

---

## Table: Customers (Dimension)

**Description:** Customer master data with contact information and segmentation.

**Record Count:** 120  
**Grain:** One row per customer  
**Primary Key:** CustomerID  

| Column Name | Data Type | Nullable | Description | Example Value | Business Rules |
|-------------|-----------|----------|-------------|---------------|----------------|
| CustomerID | Text | No | Unique customer identifier | C1000 | Primary Key; Format: C#### |
| CustomerName | Text | No | Full customer name | Ola Lewandowski | Proper case; First Last format |
| Email | Text | No | Email address | ola.lewandowski@firma.pl | Lowercase; ASCII (no diacritics) |
| Phone | Text | No | Phone number | +491773955087 | International format; No spaces |
| Country | Text | No | Customer country | Lithuania | Standardized country name |
| City | Text | No | Customer city | Vilnius | Proper case |
| Segment | Text | No | Customer segment | VIP | Values: VIP, Regular, New |
| JoinDate | Date | No | Customer registration date | 2023-03-19 | Valid date; Cannot be future |
| VAT | Text | Yes | VAT/Tax number | PL2880160025 | Format varies by country |

**Notes:**
- Email normalized: lowercase + Polish diacritics removed
- Phone standardized: +[country code][number] with no formatting
- Country names standardized (Poland/polska/PL → Poland)

---

## Table: Returns (Supporting)

**Description:** Post-sale return transactions linked to orders.

**Record Count:** 40  
**Grain:** One row per return record  
**Primary Key:** ReturnID  
**Foreign Key:** OrderID → Sales_2023  

| Column Name | Data Type | Nullable | Description | Example Value | Business Rules |
|-------------|-----------|----------|-------------|---------------|----------------|
| ReturnID | Text | No | Unique return identifier | R10000 | Primary Key; Format: R##### |
| OrderID | Text | No | Reference to original order | O500099 | Foreign Key to Sales_2023 |
| Reason | Text | No | Return reason category | Other | Standardized categories |
| Date | Date | No | Return processing date | 2023-05-21 | Must be >= OrderDate |
| Status | Text | No | Current return status | Pending | Values: Pending, Approved, Rejected |

**Relationship:** One-to-Many with Sales_2023 (one order can have multiple returns)

**Notes:**
- Not all orders have returns (~5% return rate)
- Separate table avoids null values in fact table

---

## Table: Fees (Supporting)

**Description:** Fee structure for sales channels (Poland market only).

**Record Count:** 6  
**Grain:** One row per Channel + Country + FeeType combination  
**Coverage:** Poland only  

| Column Name | Data Type | Nullable | Description | Example Value | Business Rules |
|-------------|-----------|----------|-------------|---------------|----------------|
| Channel | Text | No | Sales channel | Online | Values: Online, Wholesale, Retail |
| Country | Text | No | Market (always Poland) | Poland | Currently only "Poland" |
| FeeType | Text | No | Fee calculation type | % | Values: %, Fixed |
| FeeValue | Decimal | No | Fee amount or percentage | 2.5 | If %: 0-100; If Fixed: amount in PLN |

**Relationship:** Many-to-One with Sales_2023 (many sales share one fee structure)

**Notes:**
- Only Poland market currently covered
- FeeValue interpretation depends on FeeType (% vs Fixed)

---

## Table: Shipping (Supporting)

**Description:** Shipping details for delivered orders (Poland market only).

**Record Count:** 200  
**Grain:** One row per order  
**Primary Key:** OrderID  
**Coverage:** Poland orders only (~24% of total orders)  

| Column Name | Data Type | Nullable | Description | Example Value | Business Rules |
|-------------|-----------|----------|-------------|---------------|----------------|
| OrderID | Text | No | Reference to order | O881975 | Primary Key; Foreign Key to Sales_2023 |
| Carrier | Text | No | Shipping provider | DHL | Values: DHL, DPD, InPost, GLS |
| DeliveryType | Text | No | Service level | Express | Values: Express, Standard, Economy, Paczkomat |
| EstimatedDelivery | Text | No | Delivery timeframe | 2-4d | Format: #-#d (days) |
| ShippingCostPLN | Decimal | No | Shipping cost in PLN | 25.49 | Always in PLN; Must be >= 0 |
| Address | Text | No | Delivery address | al. Piłsudskiego 12/5, 90-368 Łódź | Full Polish address |

**Relationship:** One-to-One with Sales_2023 (one order has one shipping record)

**Notes:**
- Only Polish orders have shipping data
- Separate table avoids nulls for non-Polish orders (76% of data)

---

## Table: Targets (Supporting)

**Description:** Monthly sales targets by salesperson.

**Record Count:** 42  
**Grain:** One row per Salesperson + Month combination  

| Column Name | Data Type | Nullable | Description | Example Value | Business Rules |
|-------------|-----------|----------|-------------|---------------|----------------|
| Salesperson | Text | No | Sales representative name | A. Zielińska | Format: FirstInitial. LastName |
| Month | Text | No | Month name | Jan | Three-letter abbreviation |
| MonthNumber | Integer | No | Numeric month (1-12) | 1 | 1=Jan, 12=Dec; For date joins |
| Target | Decimal | No | Monthly sales target | 58637 | Target amount in PLN |
| Note | Text | Yes | Additional notes | varies | Optional comments |

**Relationship:** Many-to-One with Sales_2023 (many sales compare to one monthly target)

**Notes:**
- Long format (already unpivoted from wide format)
- MonthNumber added for easier joining with date fields
- Enables actual vs target performance analysis

---

## Data Quality Standards

### Text Fields
- **Trimming:** All leading/trailing spaces removed
- **Casing:** Proper case for names, lowercase for emails
- **Special Characters:** Removed from system fields (email, phone)
- **Diacritics:** Removed from email addresses for compatibility

### Numeric Fields
- **Decimal Separators:** Standardized to period (.)
- **Precision:** 2 decimal places for currency, 4 for rates
- **Range Validation:** All amounts must be positive

### Date Fields
- **Format:** ISO 8601 (YYYY-MM-DD)
- **Range:** Valid dates in 2023
- **Consistency:** ReturnDate >= OrderDate

### Boolean Fields
- **Values:** true/false only
- **No Nulls:** All boolean fields required

### Key Fields
- **Uniqueness:** All primary keys validated unique
- **Format Consistency:** Standardized formats enforced
- **Referential Integrity:** All foreign keys validated

---

## Business Rules & Constraints

### Sales_2023
- SalesAmount must equal Qty × UnitPrice
- OrderDate must be in 2023
- Qty must be positive integer
- UnitPrice must be positive

### Products
- Active products have current UnitCost
- EAN must be exactly 13 digits
- PackageSize follows format: # × #.## Unit

### Customers
- Email must be unique
- JoinDate cannot be in the future
- Phone must start with + for international format

### Returns
- OrderID must exist in Sales_2023
- Date must be after or equal to OrderDate
- Status must be: Pending, Approved, or Rejected

### Fees
- Country currently limited to "Poland"
- FeeValue depends on FeeType interpretation

### Shipping
- OrderID must exist in Sales_2023
- Only Polish orders included
- ShippingCostPLN must be non-negative

### Targets
- MonthNumber range: 1-12
- Target must be positive
  
---

## Calculated Fields

| Field | Table | Formula | Purpose |
|-------|-------|---------|---------|
| SalesAmount | Sales_2023 | Qty × UnitPrice | Transaction value in original currency |
| MonthNumber | Targets | Month name → Number | Enables date-based joins |

---

## Lookup Values

### Segment (Customers, Sales_2023)
- VIP
- Regular
- New

### Channel (Sales_2023, Fees)
- Wholesale
- Online
- Retail

### Status (Returns)
- Pending
- Approved
- Rejected

### Carrier (Shipping)
- DHL
- DPD
- InPost
- GLS

### DeliveryType (Shipping)
- Express
- Standard
- Economy
- Paczkomat

### FeeType (Fees)
- % (percentage)
- Fixed (fixed amount)

---

## Data Lineage

### Source Systems
- **Sales Q1/Q2:** Excel exports from CRM
- **Products:** Product catalog Excel file
- **Customers:** Customer database export
- **Returns:** Support system export
- **Fees/Shipping:** Operations spreadsheets (Poland)
- **Targets:** Sales planning spreadsheet

### Transformation Process
1. **Extract:** Loaded from Excel files
2. **Clean:** Applied custom functions (fxDate, fxNumber, fxText, etc.)
3. **Standardize:** Normalized formats and values
4. **Enrich:** Added calculated fields
5. **Validate:** Checked referential integrity
6. **Load:** Created final star schema

### Data Quality Metrics
- Duplicates removed: 15%+ of source records
- Format standardization: 100%
- null reduction: 93%
- Valid foreign keys: 100%

---

## Usage Notes

### For Analysts
- Use Sales_2023 for most queries (denormalized for performance)
- Join to supporting tables only when needed
- Remember Poland-only coverage for Fees/Shipping

### For Developers
- Maintain referential integrity when updating
- Apply custom functions for consistency
- Validate data types before loading
- Test with sample data first

### For Business Users
- SalesAmount is in original currency (check Currency field)
- Not all orders have returns/shipping data
- Targets are monthly, sales are daily
- Segment definitions may change over time

---

**Document Version:** 1.0  
**Last Updated:** September 2025  
**Maintained By:** Monika Burnejko  
**Project:** Sales 2023 Data Wrangling

