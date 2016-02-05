#!/usr/bin/env bash

corebuild -I src -pkg async,cohttp.async,yojson,textwrap,sqlite3EZ src/strainer.byte
corebuild -I src -pkg sqlite3EZ src/init_db.byte
