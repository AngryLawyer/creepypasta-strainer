open Core.Std
open Async.Std

let potm = "http://creepypasta.wikia.com/api/v1/Articles/List?category=PotM&limit=1000"
let spotlighted = "http://creepypasta.wikia.com/api/v1/Articles/List?category=Spotlighted_Pastas&limit=1000"

let get_url_json url =
    Cohttp_async.Client.get (Uri.of_string url)
    >>= fun (_, body) ->
    Cohttp_async.Body.to_string_list body
    >>| fun strings ->
    Yojson.Basic.from_string (String.concat strings)

let get_ids_from_article_list json =
    let open Yojson.Basic.Util in
    let entries = (json |> member "items" |> to_list) in
    List.map entries ~f:(fun entry ->
        sprintf "%u" (entry |> member "id" |> to_int)
    )

let get_ids_from_url url =
    get_url_json url
    >>| get_ids_from_article_list

let get_story_from_id db id =
    get_url_json (sprintf "http://creepypasta.wikia.com/api/v1/Articles/AsSimpleJson?id=%s" id)
    >>| fun story ->
        Database.log_id db "creepypasta.wikia.com" id;
        Story_parser.parse_story story

let get_id_list () =
    Deferred.all (List.map [potm; spotlighted] ~f:fun url -> try_with (fun () -> get_ids_from_url url))
    >>| function
        | [Ok first; Ok second] -> (Ok (List.concat [first; second]))
        | otherwise ->
            let unpacked_errors = List.map otherwise ~f:(function
                | Error e -> Exn.to_string e
                |_ -> "") in
            let stringified_errors = String.concat unpacked_errors ~sep:"-" in
            Error (sprintf "COULD NOT CONNECT %s" stringified_errors)

let get_newest_story db id_list =
    match id_list with
    | head :: _ -> try_with (fun () -> get_story_from_id db head)
        >>| (function
            | Ok story -> story
            | Error e -> sprintf "COULD NOT CONNECT - %s" (Exn.to_string e))
    | [] -> return "NO STORIES FOUND"

let () =
    let db = Sqlite3EZ.db_open "creepypasta.db" in
    let _ = (get_id_list ()
    >>| fun maybe_list ->
        (match maybe_list with
        | Ok id_list ->
            let rng = Random.State.make_self_init () in
            let filtered_id_list = Database.filter_ids db "creepypasta.wikia.com" id_list in
            let shuffled = List.permute ?random_state:(Some rng) filtered_id_list in
            get_newest_story db shuffled
        | Error e ->
            return e)
    >>| fun story ->
        eprintf "%s\n" story;
        Serial.write "/dev/ttyAMA0" story;
        Sqlite3EZ.db_close db;
        Shutdown.shutdown 0
    ) in
    never_returns (Scheduler.go())
