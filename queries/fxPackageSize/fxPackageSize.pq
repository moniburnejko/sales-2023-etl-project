let
    fxPackageSize = (input as text) as text =>
        let
            unitConversions = [
                ml = [factor = 0.001, target = "L"],
                g = [factor = 0.001, target = "kg"],
                L = [factor = 1, target = "L"],
                kg = [factor = 1, target = "kg"]],
            
            cleaned = Text.Replace(Text.Replace(Text.Upper(input), "×", "x"), "X", "x"),
            parts = Text.Split(cleaned, "x"),
            
            packCount = if List.Count(parts) > 1 
                then try Number.From(Text.Select(parts{0}, {"0".."9"})) otherwise 1
                else 1,
            
            unitText = if List.Count(parts) > 1 then parts{1} else parts{0},
            numValue = try Number.From(Text.Select(unitText, {"0".."9", "."})) otherwise null,
            unitSymbol = Text.Lower(Text.Select(unitText, {"A".."Z", "a".."z"})),
            
            conversion = Record.FieldOrDefault(unitConversions, unitSymbol, null),
            finalValue = if conversion <> null and numValue <> null
                then Number.Round(numValue * conversion[factor], 2)
                else numValue,
            finalUnit = if conversion <> null then conversion[target] else unitSymbol,
            
            result = Text.From(packCount) & 
                (if finalValue <> null then " × " & Text.From(finalValue) else "") &
                (if finalUnit <> "" then " " & finalUnit else "")
        in
            result
in
    fxPackageSize