let
    fxText = (txt as text) as text =>
    let
        allowed = 
            {"A".."Z","a".."z","0".."9"," ", "."} & 
            {"Ą","Ć","Ę","Ł","Ń","Ó","Ś","Ź","Ż","ą","ć","ę","ł","ń","ó","ś","ź","ż"},
        
        toList = Text.ToList(txt),
        filtered = List.Select(toList, each List.Contains(allowed,_)),
        cleaned = Text.Combine(filtered,""),
        singleSpace = Text.Trim(Text.Replace(cleaned, "  ", " ")),
        result = Text.Proper(singleSpace)
    in
        result
in
    fxText
