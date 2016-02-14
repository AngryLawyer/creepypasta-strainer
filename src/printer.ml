open Core.Std

let esc = "\027"

let init () =
    let output = [
        esc;
        "\064";
        esc;
        "\055";
        "\007";
        "\080";
        "\002";
        "\018";
        "\035";
        "\255"
    ] in
    String.concat output ~sep:""

type justification = Left | Center | Right
let justify j =
    let output = [
        esc;
        "\097";
        match j with
        | Left -> "\000"
        | Center -> "\001"
        | Right -> "\002"
    ] in
    String.concat output ~sep:""

let with_justify j fn =
    String.concat [justify j; fn (); justify Left] ~sep:""

let with_underline fn =
    String.concat [
        esc;
        "\045";
        "\001";
        fn ();
        esc;
        "\045";
        "\000"
    ] ~sep:""
