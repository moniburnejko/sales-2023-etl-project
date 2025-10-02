let
    fxText = (txt as nullable text) as nullable text =>
    let
        result =
            if txt = null or txt = "" then null
            else
                let
                    allowed = 
            {"A".."Z","a".."z","0".."9"," ", "."} & 
            {"Ą","Ć","Ę","Ł","Ń","Ó","Ś","Ź","Ż","ą","ć","ę","ł","ń","ó","ś","ź","ż"},
      
                    toList = Text.ToList(txt),
                    filtered = List.Select(toList, each List.Contains(allowed,_)),
                    cleaned = Text.Combine(filtered,""),
                    singleSpace = Text.Trim(Text.Replace(cleaned, "  ", " ")),
                    res = Text.Proper(singleSpace)
                in
                    res
    in
        result
in
    fxText
