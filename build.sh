#!/usr/bin/env bash

corebuild -I src -pkg async,cohttp.async,yojson,textwrap,sqlite3ez src/strainer.byte
corebuild -I src -pkg sqlite3ez src/init_db.byte
