let () =
    let open Sqlite3EZ in
    with_db "creepypasta.db" (fun db ->
        exec db "CREATE TABLE IF NOT EXISTS `visited` (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            created DATETIME DEFAULT CURRENT_TIMESTAMP,
            source TEXT,
            source_id TEXT
        )"
    )
