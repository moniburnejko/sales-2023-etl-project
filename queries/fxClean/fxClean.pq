let
    fxClean = (t as table) as table =>
        let
            removeEmptyRows = Table.SelectRows(t,
                each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
                
            trimmed = Table.TransformColumns(removeEmptyRows,
                List.Transform(Table.ColumnNames(removeEmptyRows),
                    (c) => {c, (x) => if x is text then Text.Trim(x) else x, type any})),

            renamedCols = Table.TransformColumnNames(trimmed, each Text.Replace(Text.Replace(_, " ", "_"), "#", "No"))
        in
            renamedCols
in
    fxClean
