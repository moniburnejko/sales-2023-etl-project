let
    fxNumber = (numberValue as any) as nullable number =>
    let
        result =
            if numberValue = null or numberValue = "" then null
            else if numberValue is number then numberValue
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