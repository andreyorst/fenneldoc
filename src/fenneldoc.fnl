(local fenneldoc-info
       {:_DESCRIPTION "Fenneldoc - generate documentation for Fennel projects.

Generates documentation for Fennel libraries by analyzing project
metadata at runtime.

**Documentation for other modules**

- [config.fnl](./config.md) - processes configuration file.
- [parser.fnl](./parser.md) - loads the file and analyzes its metadata providing `module-info`.
- [markdown.fnl](./markdown.md) - generates Markdown from `module-info`.
- [args.fnl](./args.md) - functions for processing command line arguments.
- [doctest.fnl](./doctest.md) - documentation testing.
- [writer.fnl](./writer.md) - writing markdown into files."})

(local fenneldoc {})

(local process-config (require :config))
(local process-args (require :args))
(local test-module (require :doctest))
(local write-doc (require :writer))
(local {: module-info} (require :parser))
(local {: gen-markdown} (require :markdown))

(import-macros {: fn*} :cljlib.macros)

(fn* process-file
  "Accepts `file` as path to some Fennel module, and `config` table.
Generates module documentation and writes it to `file` with `.md`
extension, creating it if not exists."
  [file config]
  (match (module-info file config)
    module (do (when (not= config.mode :doc)
                 (test-module module config))
               (let [markdown (gen-markdown module config)]
                 (when (not= config.mode :check)
                   (write-doc markdown file module config))))
    _ (io.stderr:write "skipping " file "\n")))

(let [(files config) (-> FENNELDOC_VERSION
                         process-config
                         process-args)]
  (each [_ file (ipairs files)]
    (process-file file config)))

(setmetatable fenneldoc {:__index fenneldoc-info})

;; LocalWords:  Andrey Listopadov Fenneldoc metadata runtime config md
;; LocalWords:  fnl args doctest
