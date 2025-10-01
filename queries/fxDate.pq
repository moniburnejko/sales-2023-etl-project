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
