let
  fxLogical = (x as nullable any) as nullable logical =>
  let
     txt = if x=null then null else Text.Upper(Text.From(x)),
      result =
         if txt=null then null
         else if txt="YES" or txt="Y" or txt="TRUE" or txt="1" then true
         else if txt="NO" or txt="N" or txt="FALSE" or txt="0" then false
         else null
  in
      result
in fxLogical
