import sqlite3
conn = sqlite3.connect('creepypasta.db')

c = conn.cursor()

c.execute('''CREATE TABLE IF NOT EXISTS `visited` (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            created DATETIME DEFAULT CURRENT_TIMESTAMP,
            source TEXT,
            source_id TEXT
        )''')

conn.commit()
conn.close()
