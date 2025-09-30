# Data Dictionary

## 📚 Overview

This data dictionary provides comprehensive documentation of all tables, fields, data types, and business rules in the Sales 2023 dataset following a star schema design.

**Version:** 1.0  
**Last Updated:** September 2025  
**Total Tables:** 7  
**Total Records:** ~1,500  
**Model Type:** Star Schema with denormalized fact table

---

## 🌟 Table: Sales_2023 (Fact Table)

**Description:** Central fact table containing all sales transactions with denormalized customer and product attributes for query performance.

**Record Count:** 850  
**Grain:** One row per order line item  
**Primary Key:** OrderID  

### Fields

| Column Name | Data Type | Nullable | Description | Example | Business Rules |
|-------------|-----------|:--------:|-------------|---------|----------------|
| **OrderID** | Text | ❌ | Unique order identifier | O312146 | PK; Format: O######; Must be unique |
| **OrderDate** | Date | ❌ | Transaction date | 2023-03-29 | Valid date in 2023 |
| **CustomerID** | Text | ❌ | Customer identifier | C1112 | FK to Customers; Format: C#### |
| CustomerName | Text | ❌ | Customer full name (denorm.) | Kasia Mazur | Proper case |
| Email | Text | ❌ | Customer email (denorm.) | kasia.mazur@mail.com | Lowercase; ASCII only |
| Phone | Text | ❌ | Customer phone (denorm.) | +420623497528 | No spaces/dashes |
| CustomerCountry | Text | ❌ | Customer's country (denorm.) | Poland | Standardized name |
| CustomerCity | Text | ❌ | Customer's city (denorm.) | Gdańsk | Proper case |
| Segment | Text | ❌ | Customer segment (denorm.) | VIP | Values: VIP, Regular, New |
| **ProductSKU** | Text | ❌ | Product identifier | P3091-A | FK to Products; Format: P####-A |
| ProductName | Text | ❌ | Product name (denorm.) | Laundry Liquid | Proper case |
| Category | Text | ❌ | Product category (denorm.) | Household | Standardized |
| Subcategory | Text | ❌ | Product subcategory (denorm.) | Paper | Standardized |
| UnitCost | Decimal | ❌ | Product unit cost (denorm.) | 3.30 | PLN; > 0 |
| Qty | Integer | ❌ | Quantity sold | 5 | Must be > 0 |
| UnitPrice | Decimal | ❌ | Selling price per unit | 175.26 | Original currency |
| **SalesAmount** | Decimal | ❌ | Calculated value | 876.30 | = Qty × UnitPrice |
| Currency | Text | ❌ | Transaction currency | PLN | ISO codes |
| OrderCountry | Text | ❌ | Delivery country | Latvia | May differ from CustomerCountry |
| OrderCity | Text | ❌ | Delivery city | Riga | May differ from CustomerCity |
| Salesperson | Text | ❌ | Sales representative | E. Dabrowska | Format: F. LastName |
| Channel | Text | ❌ | Sales channel | Wholesale | Wholesale/Online/Retail |

**Notes:**
- ⚡ SalesAmount is calculated field (not stored in source)
- 🔄 Customer and Product attributes denormalized for performance
- 📍 OrderCountry/City may differ from Customer location (ship-to address)

---

## 📦 Table: Products (Dimension)

**Description:** Product master data with specifications and attributes.

**Record Count:** 60  
**Grain:** One row per product  
**Primary Key:** ProductSKU  

### Fields

| Column Name | Data Type | Nullable | Description | Example | Business Rules |
|-------------|-----------|:--------:|-------------|---------|----------------|
| **ProductSKU** | Text | ❌ | Unique product ID | P2824-A | PK; Format: P####-A |
| ProductName | Text | ❌ | Product name | Bbq Chips | Proper case |
| Category | Text | ❌ | Main category | Beverages | ~10 categories |
| Subcategory | Text | ❌ | Subcategory | Coffee | ~30 subcategories |
| UnitCost | Decimal | ❌ | Cost per unit | 34.48 | PLN; > 0 |
| Active | Boolean | ❌ | Availability status | false | true/false |
| Supplier | Text | ✅ | Supplier name | Baltic Co. | Can be null |
| PackageSize | Text | ❌ | Standardized format | 1 × 1 kg | Format: N × X.XX Unit |
| EAN | Text | ❌ | Barcode | 130201276659 | 13 digits |

---

## 👥 Table: Customers (Dimension)

**Description:** Customer master data with contact information and segmentation.

**Record Count:** 120  
**Grain:** One row per customer  
**Primary Key:** CustomerID  

### Fields

| Column Name | Data Type | Nullable | Description | Example | Business Rules |
|-------------|-----------|:--------:|-------------|---------|----------------|
| **CustomerID** | Text | ❌ | Unique customer ID | C1000 | PK; Format: C#### |
| CustomerName | Text | ❌ | Full name | Ola Lewandowski | Proper case |
| Email | Text | ❌ | Email address | ola.lew@firma.pl | Lowercase; ASCII |
| Phone | Text | ❌ | Phone number | +491773955087 | International format |
| Country | Text | ❌ | Customer country | Lithuania | Standardized |
| City | Text | ❌ | Customer city | Vilnius | Proper case |
| Segment | Text | ❌ | Customer segment | VIP | VIP/Regular/New |
| JoinDate | Date | ❌ | Registration date | 2023-03-19 | Valid date |
| VAT | Text | ✅ | VAT/Tax number | PL2880160025 | Country-specific |

---

## ↩️ Table: Returns (Supporting)

**Description:** Post-sale return transactions linked to orders.

**Record Count:** 40  
**Grain:** One row per return  
**Primary Key:** ReturnID  
**Relationship:** One-to-Many with Sales_2023  

### Fields

| Column Name | Data Type | Nullable | Description | Example | Business Rules |
|-------------|-----------|:--------:|-------------|---------|----------------|
| **ReturnID** | Text | ❌ | Unique return ID | R10000 | PK; Format: R##### |
| OrderID | Text | ❌ | Original order ref | O500099 | FK to Sales_2023 |
| Reason | Text | ❌ | Return reason | Other | Standardized |
| Date | Date | ❌ | Return date | 2023-05-21 | >= OrderDate |
| Status | Text | ❌ | Return status | Pending | Pending/Approved/Rejected |

---

## 💰 Table: Fees (Supporting)

**Description:** Fee structure for sales channels (Poland market only).

**Record Count:** 6  
**Coverage:** 🇵🇱 Poland only  

### Fields

| Column Name | Data Type | Nullable | Description | Example | Business Rules |
|-------------|-----------|:--------:|-------------|---------|----------------|
| Channel | Text | ❌ | Sales channel | Online | Online/Wholesale/Retail |
| Country | Text | ❌ | Market | Poland | Currently "Poland" only |
| FeeType | Text | ❌ | Fee type | % | % or Flat |
| FeeValue | Decimal | ❌ | Fee amount | 2.5 | If %: 0-100; If Flat: PLN |

---

## 🚚 Table: Shipping (Supporting)

**Description:** Shipping details for delivered orders (Poland market only).

**Record Count:** 200  
**Coverage:** 🇵🇱 Poland orders only (~24% of total)  
**Primary Key:** OrderID  

### Fields

| Column Name | Data Type | Nullable | Description | Example | Business Rules |
|-------------|-----------|:--------:|-------------|---------|----------------|
| **OrderID** | Text | ❌ | Order reference | O881975 | PK; FK to Sales_2023 |
| Carrier | Text | ❌ | Shipping provider | DHL | DHL/DPD/InPost/GLS |
| DeliveryType | Text | ❌ | Service level | Express | Express/Standard/Economy |
| EstimatedDelivery | Text | ❌ | Timeframe | 2-4d | Format: #-#d |
| ShippingCostPLN | Decimal | ❌ | Cost in PLN | 25.49 | >= 0 |
| Address | Text | ❌ | Delivery address | al. Piłsudskiego 12/5 | Full address |

---

## 🎯 Table: Targets (Supporting)

**Description:** Monthly sales targets by salesperson.

**Record Count:** 42  
**Grain:** One row per Salesperson + Month  

### Fields

| Column Name | Data Type | Nullable | Description | Example | Business Rules |
|-------------|-----------|:--------:|-------------|---------|----------------|
| Salesperson | Text | ❌ | Sales rep name | A. Zielińska | Format: F. LastName |
| Month | Text | ❌ | Month name | Jan | Three-letter abbr. |
| MonthNumber | Integer | ❌ | Numeric month | 1 | 1-12 |
| Target | Decimal | ❌ | Monthly target | 58637 | PLN; > 0 |
| Note | Text | ✅ | Additional notes | varies | Optional |

---

## 📏 Data Quality Standards

### Text Fields
- ✂️ **Trimming:** All leading/trailing spaces removed
- 📝 **Casing:** Proper case for names, lowercase for emails
- 🚫 **Special Characters:** Removed from system fields
- 🔤 **Diacritics:** Removed from emails for compatibility

### Numeric Fields
- **Decimal Separator:** Period (.)
- **Precision:** 2 decimals for currency
- **Range:** All amounts > 0

### Date Fields
- **Format:** ISO 8601 (YYYY-MM-DD)
- **Range:** Valid dates in 2023
- **Logic:** ReturnDate >= OrderDate

### Boolean Fields
- **Values:** true/false only
- **Required:** No nulls allowed

---

## 🔧 Calculated Fields

| Field | Table | Formula | Purpose |
|-------|-------|---------|---------|
| SalesAmount | Sales_2023 | Qty × UnitPrice | Transaction value |
| MonthNumber | Targets | Month name → Number | Date joins |

---

## 📊 Data Quality Metrics

| Metric | Result |
|--------|--------|
| **Duplicates Removed** | 15%+ of source records |
| **Format Standardization** | 100% |
| **Null Reduction** | 93% |
| **Valid Foreign Keys** | 100% |
| **Referential Integrity** | 100% |

---

## 📝 Usage Notes

### For Analysts
- Use Sales_2023 for most queries (denormalized for performance)
- Join to supporting tables only when needed
- Remember Poland-only coverage for Fees/Shipping

### For Developers
- Maintain referential integrity when updating
- Apply custom functions for consistency
- Validate data types before loading

### For Business Users
- SalesAmount is in original currency (check Currency field)
- Not all orders have returns/shipping data
- Targets are monthly, sales are daily

---

*Version 1.0 | Last Updated: September 2025*
