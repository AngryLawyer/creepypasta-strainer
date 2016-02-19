
let write file text =
    let handle = Unix.openfile file [Unix.O_APPEND; O_WRONLY] 0o640 in
    let terminal_io = Unix.tcgetattr handle in
    terminal_io.c_obaud <- 19200;
    Unix.tcsetattr handle TCSANOW terminal_io;
    let _ = Unix.write handle text 0 (String.length text) in
    ()
