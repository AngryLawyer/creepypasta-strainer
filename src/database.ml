open Core.Std

let filter_ids db source ids =
    let command = sprintf "SELECT source_id FROM `visited` WHERE `source`='%s'" source in
    let stmt = Sqlite3EZ.make_statement db command in
    let existing = Sqlite3EZ.statement_query stmt [||] (fun arr -> Sqlite3EZ.Data.to_string (arr.(0))) (fun value collection -> value :: collection) [] in
    List.filter ids ~f: (fun id -> (List.exists existing ~f:fun old -> old = id) = false )

let log_id db source id =
    Sqlite3EZ.exec db (sprintf "INSERT INTO `visited` (`source`, `source_id`) VALUES ('%s', '%s')" source id)
