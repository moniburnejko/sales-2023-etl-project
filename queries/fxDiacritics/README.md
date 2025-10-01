# fxDiacritics - Polish Character Normalization Function

## Purpose
Converts Polish diacritical characters (ą, ć, ę, ł, ń, ó, ś, ż, ź) to their ASCII equivalents for system compatibility. Essential for email addresses, URLs, file paths, and any system that doesn't support UTF-8 encoding.

## Why This Matters
Many legacy systems, databases, and email servers reject or corrupt Polish special characters. This function ensures data compatibility across all systems while preserving readability. Critical for data integration where Polish names appear in fields that must be ASCII-only (emails, usernames, system IDs).

## Function Code
```m
let
    fxDiacritics = (x as nullable text) as nullable text =>
    let
        t = if x=null then null else x,
        pairs = {
            {"ą","a"}, {"ć","c"}, {"ę","e"}, {"ł","l"}, {"ń","n"}, 
            {"ó","o"}, {"ś","s"}, {"ż","z"}, {"ź","z"},
            {"Ą","A"}, {"Ć","C"}, {"Ę","E"}, {"Ł","L"}, {"Ń","N"}, 
            {"Ó","O"}, {"Ś","S"}, {"Ż","Z"}, {"Ź","Z"}
        },
        result = if t=null then null else
            List.Accumulate(pairs, t, (state, p) => Text.Replace(state, p{0}, p{1}))
    in
        result
in
    fxDiacritics
```

## Usage
### Single Value Conversion
```m
// Test various Polish names and text
= fxDiacritics("Małgorzata Wiśniewski")    // Returns: "Malgorzata Wisniewski"
= fxDiacritics("Łódź")                     // Returns: "Lodz"
= fxDiacritics("ćma")                      // Returns: "cma"
= fxDiacritics("ZĄBKOWSKA")                // Returns: "ZABKOWSKA"
= fxDiacritics(null)                       // Returns: null
= fxDiacritics("No Polish chars")          // Returns: "No Polish chars"
```

### Apply to Table Column (Email Normalization)
```m
let
    source = Excel.Workbook(File.Contents("C:\data\customers.xlsx")),
    
    // Normalize email addresses for system compatibility
    normalizedEmails = Table.TransformColumns(source, 
        {"Email", each fxDiacritics(_), type text})
in
    normalizedEmails
```

## What It Handles
| Polish Character | ASCII Equivalent | Example Input | Example Output |
|------------------|------------------|---------------|----------------|
| ą / Ą | a / A | Dąbrowski | Dabrowski |
| ć / Ć | c / C | Ćwikła | Cwikla | 
| ę / Ę | e / E | Zięba | Zieba | 
| ł / Ł | l / L | Łódź | Lodz |
| ń / Ń | n / N | Gdańsk | Gdansk |
| ó / Ó | o / O | Kraków | Krakow |
| ś / Ś | s / S | Śląsk | Slask |
| ż / Ż | z / Z | Wróżka | Wrozka |
| ź / Ź | z / Z | Źrebak | Zrebak |

## Real-World Impact
### Sales 2023 ETL Project Results
#### Before fxDiacritics:
- Email addresses rejected by CRM system
- "małgorzata@example.pl" caused import errors
- Database queries failed on Polish names
- Manual cleanup of 200+ customer records
#### After fxDiacritics:
- 100% email compatibility with legacy systems
- Zero import errors from Polish characters
- Automated normalization - no manual intervention
- Preserved original data in separate column for reference

## Error Handling
The Function Handles:
- Null values → Returns null
- Empty strings → Returns empty string
- Text with no Polish characters → Returns unchanged
- Mixed case → Converts both upper and lowercase
- Multiple diacritics in one word → Replaces all
- Non-text inputs → Handles gracefully when used with type conversion

## Best Practices
#### Do:
- Preserve original in separate column for reference (important for customer names)
- Use with Text.Lower() for email normalization: Text.Lower(fxDiacritics(_))
- Apply to specific columns where ASCII is required (Email, Username, SystemID)
#### Don't:
- Apply to display names if Unicode support exists (users prefer seeing "Łódź" not "Lodz")
- Use on already normalized data (unnecessary overhead)
- Apply to non-Polish text exclusively (harmless but wasteful)
- Lose original data - always keep source column when normalizing customer-facing fields

## Extending the Function
#### Add Additional Languages
```m
// German umlauts example
pairs = {
    // Polish
    {"ą","a"}, {"ć","c"}, {"ę","e"}, {"ł","l"}, {"ń","n"}, 
    {"ó","o"}, {"ś","s"}, {"ż","z"}, {"ź","z"},
    {"Ą","A"}, {"Ć","C"}, {"Ę","E"}, {"Ł","L"}, {"Ń","N"}, 
    {"Ó","O"}, {"Ś","S"}, {"Ż","Z"}, {"Ź","Z"},
    
    // German (add if needed)
    {"ä","ae"}, {"ö","oe"}, {"ü","ue"}, {"ß","ss"},
    {"Ä","Ae"}, {"Ö","Oe"}, {"Ü","Ue"}}
```
    
#### Create Language-Specific Variants
```m
// Polish-only version (current)
= fxDiacritics("Łódź Müller")  // "Lodz Müller"

// Multi-language version (extended)
= fxDiacriticsExtended("Łódź Müller")  // "Lodz Muller"
```m
