open Core.Std
open Async.Std

(* endpoints:
 * http://creepypasta.wikia.com/api/v1/Articles/List?category=PotM&limit=1000
 * http://creepypasta.wikia.com/api/v1/Articles/List?category=Spotlighted_Pastas&limit=1000
 *)

let get_article_list () =
    Cohttp_async.Client.get (Uri.of_string "http://creepypasta.wikia.com/api/v1/Articles/List?category=PotM&limit=1000")
    >>= fun (_, body) ->
    Cohttp_async.Body.to_string_list body
    >>| fun strings ->
    eprintf "%s" (String.concat strings)

let () =
    let _ = get_article_list () in
    never_returns (Scheduler.go())
