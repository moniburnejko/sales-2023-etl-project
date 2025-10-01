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