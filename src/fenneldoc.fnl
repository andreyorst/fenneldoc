(local fenneldoc {:_VERSION "0.0.4"
                  :_COPYRIGHT "Copyright (C) 2020 Andrey Orst"
                  :_LICENSE "[MIT](https://gitlab.com/andreyorst/fenneldoc/-/raw/master/LICENSE)"
                  :_DESCRIPTION "Fenneldoc - generate documentation for Fennel projects.

Generates documentation for Fennel libraries by analyzing project
metadata at runtime.

**Documentation for other modules**

- [config.fnl](./config.md) - processes configuration file.
- [parser.fnl](./parser.md) - loads the file and analyzes its metadata providing `module-info`.
- [markdown.fnl](./markdown.md) - generates Markdown from `module-info`."})

(local process-file (require :parser))
(local process-config (require :config))

(fn help []
  (print "Usage: fenneldoc [flags] [files]

Create documentation for your Fennel project.

Value flags:
  --version-key     _VERSION     : key to use to get the version of the module.
  --description-key _DESCRIPTION : key to use to get the description of the module.
  --license-key     _LICENSE     : key to use to get license information of the module.
  --copyright-key   _COPYRIGHT   : key to use to get copyright information of the module.
  --out-dir         ./doc        : output directory for generated documentation.

Toggle flags:
  --[no-]silent                  : (don't) report errors.
  --[no-]function-signatures     : (don't) generate function signatures in documentation.
  --[no-]final-comment           : (don't) insert final comment with fenneldoc version.
  --[no-]license                 : (don't) insert license information from the module.
  --[no-]toc                     : (don't) generate table of contents.
  --[no-]copyright               : (don't) insert copyright information.

Other flags:
  --help                         : print this message and exit.

All keys have higher precedence than configuration file, therefore
values passed with keys will override folowing values in
`.fenneldoc'.

Each toggle key has two variants with and without `no'.  For example,
passing `--no-toc' will disable generation of contents table, and
`--toc` will anable it.")
  (os.exit 0))


(fn process-args [config]
  "Process command line arguments"
  (let [files []]
    (var (i flag) (next arg))
    (while (and i (> i 0))
      (match flag
        :--version-key (do (tset arg i nil)
                           (set (i flag) (next arg i))
                           (if (and i (> i 0)) (set config.keys.version flag)
                               (error "expected value for --version-key" 2)))
        :--license-key (do (tset arg i nil)
                           (set (i flag) (next arg i))
                           (if (and i (> i 0)) (set config.keys.license flag)
                               (error "expected value for --license-key" 2)))
        :--description-key (do (tset arg i nil)
                               (set (i flag) (next arg i))
                               (if (and i (> i 0)) (set config.keys.description flag)
                                   (error "expected value for --description-key" 2)))
        :--copyright-key (do (tset arg i nil)
                             (set (i flag) (next arg i))
                             (if (and i (> i 0)) (set config.keys.copyright flag)
                                 (error "expected value for --copyright-key" 2)))
        :--out-dir (do (tset arg i nil)
                       (set (i flag) (next arg i))
                       (if (and i (> i 0)) (set config.out-dir flag)
                           (error "expected value for --out-dir" 2)))

        ;; TODO: currently has no effect
        :--silent    (set default-config.silent true)
        :--no-silent (set default-config.silent false)

        :--function-signatures    (set config.function-signatures true)
        :--no-function-signatures (set config.function-signatures false)

        :--final-comment    (set config.insert-comment true)
        :--no-final-comment (set config.insert-comment false)

        :--copyright    (set config.insert-copyright true)
        :--no-copyright (set config.insert-copyright false)

        :--license    (set config.insert-license true)
        :--no-license (set config.insert-license false)

        :--toc    (set config.toc true)
        :--no-toc (set config.toc false)

        :--help (help)
        _ (table.insert files flag))
      (tset arg i nil)
      (set (i flag) (next arg i)))
    (set config.fenneldoc-version fenneldoc._VERSION)
    (values files config)))


(let [(files config) (process-args (process-config))]
  (each [_ file (ipairs files)]
    (process-file file config)))


fenneldoc