open Core.Std

let concat_newlines =
    String.concat ~sep:"\n"

let wrap x =
    concat_newlines (Wrapper.wrap (Wrapper.make 50) x)

let parse_title json =
    let open Yojson.Basic.Util in
    let centred_text = Printer.with_justify Printer.Center (fun () -> wrap (json |> member "title" |> to_string)) in
    concat_newlines [
        centred_text;
        ""
    ]

let parse_list_element json =
    let open Yojson.Basic.Util in
    wrap (sprintf "* %s" (json |> member "text" |> to_string))

let parse_list json =
    let open Yojson.Basic.Util in
    concat_newlines (List.map (json |> to_list) ~f:parse_list_element)

let parse_content json =
    let open Yojson.Basic.Util in
    match (json |> member "type" |> to_string) with
    | "paragraph" -> concat_newlines [wrap (json |> member "text" |> to_string); ""]
    | "list" -> parse_list (json |> member "elements")
    | _ -> ""

let parse_content_list json =
    let open Yojson.Basic.Util in
    concat_newlines (List.map (json |> member "content" |> to_list) ~f:parse_content)

let parse_section json =
    concat_newlines [
        parse_title json;
        parse_content_list json
    ]

let parse_story json =
    let open Yojson.Basic.Util in
    let sections = json |> member "sections" |> to_list in
    let text_sections = List.map sections ~f:parse_section in
    String.concat [Printer.init (); (String.concat ~sep:"\n" text_sections)] ~sep:""
