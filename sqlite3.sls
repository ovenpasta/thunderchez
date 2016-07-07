;;;; sqlite3.scm
;;;; :tabSize=2:indentSize=2:noTabs=true:
;;;; bindings to the SQLite3 database library

#!chezscheme
(library (sqlite3)
  (export 
    ;; procedures
    open-database 
    ;define-collation
    ;define-function
    set-busy-handler!
    ;make-busy-timeout
    interrupt!
    auto-committing?
    change-count
    last-insert-rowid
    finalize!
    prepare
    source-sql
    reset!
    bind-parameter-count
    bind-parameter-index
    bind-parameter-name
    bind!
    bind-parameters!
    step!
    column-count
    column-type
    column-declared-type
    column-name
    column-data
    call-with-temporary-statements
    execute
    update
    first-result
    first-row
    fold-row
    for-each-row
    map-row
    with-transaction
    sql-complete?
    database-version
    database-memory-used
    database-memory-highwater
    enable-shared-cache!
    enable-load-extension!)

  (import 
   (chezscheme)
   (srfi s0 cond-expand)
   (srfi s2 and-let)
   (matchable)
   (only (srfi s13 strings) string-contains-ci)
   (srfi s11 let-values)
   (srfi s26 cut)
   (sql-null))

  (include "sqlite3.scm")

 ; (load-shared-object "libsqlite3.so.0")

) ; library sqlite3

  
(warning 'sqlite3 "remember to load the dynamic library: Example:  (load-shared-object \"libsqlite3.so.0\")")
