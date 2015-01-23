(* mllib
 * Copyright (C) 2015 Red Hat Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *)

(* This file tests the JSON module. *)

open OUnit

(* Utils. *)
let assert_equal_string = assert_equal ~printer:(fun x -> x)

(* "basic" suite. *)
let test_empty () =
  let doc = [] in
  assert_equal_string "{}" (JSON.string_of_doc doc);
  assert_equal_string "{
}" (JSON.string_of_doc ~fmt:JSON.Indented doc)

let test_string () =
  let doc = [ "test_string", JSON.String "foo"; ] in
  assert_equal_string "{ \"test_string\": \"foo\" }"
    (JSON.string_of_doc doc);
  assert_equal_string "{
  \"test_string\": \"foo\"
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

let test_bool () =
  let doc = [ "test_true", JSON.Bool true;
              "test_false", JSON.Bool false ] in
  assert_equal_string
    "{ \"test_true\": true, \"test_false\": false }"
    (JSON.string_of_doc doc);
  assert_equal_string
    "{
  \"test_true\": true,
  \"test_false\": false
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

let test_int () =
  let doc = [ "test_zero", JSON.Int 0;
              "test_pos", JSON.Int 5;
              "test_neg", JSON.Int (-5);
              "test_pos64", JSON.Int64 (Int64.of_int 10);
              "test_neg64", JSON.Int64 (Int64.of_int (-10)); ] in
  assert_equal_string
    "{ \"test_zero\": 0, \"test_pos\": 5, \"test_neg\": -5, \"test_pos64\": 10, \"test_neg64\": -10 }"
    (JSON.string_of_doc doc);
  assert_equal_string
    "{
  \"test_zero\": 0,
  \"test_pos\": 5,
  \"test_neg\": -5,
  \"test_pos64\": 10,
  \"test_neg64\": -10
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

let test_list () =
  let doc = [ "item", JSON.List [ JSON.String "foo"; JSON.Int 10; JSON.Bool true ] ] in
  assert_equal_string
    "{ \"item\": [ \"foo\", 10, true ] }"
    (JSON.string_of_doc doc);
  assert_equal_string
    "{
  \"item\": [
    \"foo\",
    10,
    true
  ]
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

let test_nested_dict () =
  let doc = [
      "item", JSON.Dict [ "int", JSON.Int 5; "string", JSON.String "foo"; ];
      "last", JSON.Int 10;
    ] in
  assert_equal_string
    "{ \"item\": { \"int\": 5, \"string\": \"foo\" }, \"last\": 10 }"
    (JSON.string_of_doc doc);
  assert_equal_string
    "{
  \"item\": {
    \"int\": 5,
    \"string\": \"foo\"
  },
  \"last\": 10
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

let test_nested_nested_dict () =
  let doc = [
      "item", JSON.Dict [ "int", JSON.Int 5;
        "item2", JSON.Dict [ "int", JSON.Int 0; ];
      ];
      "last", JSON.Int 10;
    ] in
  assert_equal_string
    "{ \"item\": { \"int\": 5, \"item2\": { \"int\": 0 } }, \"last\": 10 }"
    (JSON.string_of_doc doc);
  assert_equal_string
    "{
  \"item\": {
    \"int\": 5,
    \"item2\": {
      \"int\": 0
    }
  },
  \"last\": 10
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

let test_escape () =
  let doc = [ "test_string", JSON.String "test \" ' \n \b \r \t"; ] in
  assert_equal_string "{ \"test_string\": \"test \\\" ' \\n \\b \\r \\t\" }"
    (JSON.string_of_doc doc);
  assert_equal_string "{
  \"test_string\": \"test \\\" ' \\n \\b \\r \\t\"
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

(* "examples" suite. *)
let test_qemu () =
  let doc = [
    "file.driver", JSON.String "https";
    "file.url", JSON.String "https://libguestfs.org";
    "file.timeout", JSON.Int 60;
    "file.readahead", JSON.Int (64 * 1024 * 1024);
  ] in
  assert_equal_string
    "{ \"file.driver\": \"https\", \"file.url\": \"https://libguestfs.org\", \"file.timeout\": 60, \"file.readahead\": 67108864 }"
    (JSON.string_of_doc doc);
  assert_equal_string
    "{
  \"file.driver\": \"https\",
  \"file.url\": \"https://libguestfs.org\",
  \"file.timeout\": 60,
  \"file.readahead\": 67108864
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

let test_builder () =
  let doc = [
    "version", JSON.Int 1;
    "sources", JSON.List [
      JSON.Dict [
        "uri", JSON.String "http://libguestfs.org/index";
      ];
    ];
    "templates", JSON.List [
      JSON.Dict [
        "os-version", JSON.String "phony-debian";
        "full-name", JSON.String "Phony Debian";
        "arch", JSON.String "x86_64";
        "size", JSON.Int64 (Int64.of_int 536870912);
        "notes", JSON.Dict [
          "C", JSON.String "Phony Debian look-alike used for testing.";
        ];
        "hidden", JSON.Bool false;
      ];
      JSON.Dict [
        "os-version", JSON.String "phony-fedora";
        "full-name", JSON.String "Phony Fedora";
        "arch", JSON.String "x86_64";
        "size", JSON.Int64 (Int64.of_int 1073741824);
        "notes", JSON.Dict [
          "C", JSON.String "Phony Fedora look-alike used for testing.";
        ];
        "hidden", JSON.Bool false;
      ];
    ];
  ] in
  assert_equal_string
    "{
  \"version\": 1,
  \"sources\": [
    {
      \"uri\": \"http://libguestfs.org/index\"
    }
  ],
  \"templates\": [
    {
      \"os-version\": \"phony-debian\",
      \"full-name\": \"Phony Debian\",
      \"arch\": \"x86_64\",
      \"size\": 536870912,
      \"notes\": {
        \"C\": \"Phony Debian look-alike used for testing.\"
      },
      \"hidden\": false
    },
    {
      \"os-version\": \"phony-fedora\",
      \"full-name\": \"Phony Fedora\",
      \"arch\": \"x86_64\",
      \"size\": 1073741824,
      \"notes\": {
        \"C\": \"Phony Fedora look-alike used for testing.\"
      },
      \"hidden\": false
    }
  ]
}"
    (JSON.string_of_doc ~fmt:JSON.Indented doc)

(* Suites declaration. *)
let suite =
  TestList ([
    "basic" >::: [
      "empty" >:: test_empty;
      "string" >:: test_string;
      "bool" >:: test_bool;
      "int" >:: test_int;
      "list" >:: test_list;
      "nested dict" >:: test_nested_dict;
      "nested nested dict" >:: test_nested_nested_dict;
      "escape" >:: test_escape;
    ];
    "examples" >::: [
      "qemu" >:: test_qemu;
      "virt-builder" >:: test_builder;
    ];
  ])

let _ =
  run_test_tt_main suite

let () =
  Printf.fprintf stderr "\n"
