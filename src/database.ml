open Core.Std

let filter_ids db source ids =
    let command = sprintf "SELECT id FROM `visited` WHERE `source`='%s'" source in
    let stmt = Sqlite3EZ.make_statement db command in
    let existing = Sqlite3EZ.statement_query stmt [||] (fun arr -> 0) (fun value collection -> []) [] in
    []
