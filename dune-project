(lang dune 3.15)

(name nix_riot_example)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name nix_riot_example)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends
 (ocaml (>= "5.1"))
 dune
 (riot (>= "0.0.9"))
 (telemetry (>= "0.0.1"))
 (odoc (and :with-doc (>= "2.2.2"))))
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
