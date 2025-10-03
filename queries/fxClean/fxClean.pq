let
    fxClean = (t as table) as table =>
        let
            removeEmptyRows = Table.SelectRows(t,
                each List.NonNullCount(Record.FieldValues(_)) > 0),
            
            textColumns = List.Select(
                Table.ColumnNames(removeEmptyRows),
                each Value.Type(Table.Column(removeEmptyRows, _){0}) = type text),
            
            trimmed = Table.TransformColumns(
                removeEmptyRows,
                List.Transform(textColumns, (col) => 
                    {col, each if _ = null then null else Text.Trim(_), type nullable text})),
            
            renamedCols = Table.TransformColumnNames(trimmed, 
            each Text.Replace(Text.Replace(_, " ", "_"), "#", "No"))
        in
            renamedCols
in
    fxClean
