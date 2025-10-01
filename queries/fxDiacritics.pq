let
fxDiacritics = (x as nullable text) as nullable text =>
  let
      t = if x=null then null else x,
     pairs = {
         {"ą","a"}, {"ć","c"}, {"ę","e"}, {"ł","l"}, {"ń","n"}, {"ó","o"}, {"ś","s"}, {"ż","z"}, {"ź","z"},
          {"Ą","A"}, {"Ć","C"}, {"Ę","E"}, {"Ł","L"}, {"Ń","N"}, {"Ó","O"}, {"Ś","S"}, {"Ż","Z"}, {"Ź","Z"}
     },
     result = if t=null then null else
            List.Accumulate(pairs, t, (state, p) => Text.Replace(state, p{0}, p{1}))
  in
     result
in
  fxDiacritics