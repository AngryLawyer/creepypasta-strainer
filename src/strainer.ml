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
        entry |> member "id" |> to_int
    )

let get_ids_from_url url =
    get_url_json url
    >>| get_ids_from_article_list

let get_story_from_id id =
    get_url_json (sprintf "http://creepypasta.wikia.com/api/v1/Articles/AsSimpleJson?id=%u" id)
    >>| Story_parser.parse_story

let () =
    let _ = ( Deferred.all (List.map [potm; spotlighted] ~f:get_ids_from_url)
    >>| fun id_lists ->
        let id_list = List.concat id_lists in
        let rng = Random.State.make_self_init () in
        let shuffled = List.permute ?random_state:(Some rng) id_list in
        get_story_from_id (List.hd_exn shuffled)
    >>| fun story ->
        eprintf "%s\n" story;
        Shutdown.shutdown 0
    ) in
    never_returns (Scheduler.go())
