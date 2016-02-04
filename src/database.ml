open Core.Std

let exists db source id =
    let command = sprintf "SELECT id FROM `visited` WHERE `source`=`%s` AND `source_id` = `%s`" source id in
    let stmt = Sqlite3EZ.make_statement db command in
    ()
