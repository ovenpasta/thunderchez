;;;; sqlite3.scm
;;;; :tabSize=2:indentSize=2:noTabs=true:
;;;; bindings to the SQLite3 database library

#!chezscheme
(library
 (sqlite3)
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

 #;(define (sqlite3-library-init))
 (define libinit
   (begin
     (case (machine-type)
       [(i3nt a6nt i3mw a6mw)
	(load-shared-object "sqlite3.dll")]
       [else
	(load-shared-object "libsqlite3.so.0")])))
 ;(define libinit (begin (load-shared-object "sqlite3.dll")))
 ;; compatibility functions
 (define (hashtable-walk ht f)
   (vector-for-each (lambda (x)
                      (f x (hashtable-ref ht x #f)))
                    (hashtable-keys ht)))

 (define (->string x)
   (with-output-to-string (lambda () (display x))))

 (define (conc . args)
   (apply string-append (map ->string args)) )

;;; Foreign types & values

 ;; Enumeration and constant definitions
 (define sqlite3:status
   '((ok         .  0) ; Successful result (#f?)
     (error      .  1) ; SQL error or missing database
     (internal   .  2) ; NOT USED. Internal logic error in SQLite
     (permission .  3) ; Access permission denied
     (abort      .  4) ; Callback routine requested an abort
     (busy       .  5) ; The database file is locked
     (locked     .  6) ; A table in the database is locked
     (no-memory  .  7) ; A malloc() failed
     (read-only  .  8) ; Attempt to write a readonly database
     (interrupt  .  9) ; Operation terminated by sqlite3_interrupt()
     (io-error   . 10) ; Some kind of disk I/O error occurred
     (corrupt    . 11) ; The database disk image is malformed
     (not-found  . 12) ; NOT USED. Table or record not found
     (full       . 13) ; Insertion failed because database is full
     (cant-open  . 14) ; Unable to open the database file
     (protocol   . 15) ; NOT USED. Database lock protocol error
     (empty      . 16) ; Database is empty
     (schema     . 17) ; The database schema changed
     (too-big    . 18)  ; String or BLOB exceeds size limit
     (constraint . 19) ; Abort due to contraint violation
     (mismatch   . 20) ; Data type mismatch
     (misuse     . 21) ; Library used incorrectly
     (no-lfs     . 22) ; Uses OS features not supported on host
     (auth       . 23) ; Authorization denied
     (format     . 24) ; Auxiliary database format error
     (range      . 25) ; 2nd parameter to sqlite3_bind out of range
     (not-a-db   . 26) ; File opened that is not a database file
     (notice     . 27) ; Notifications from sqlite3_log()
     (warning    . 28) ; Warnings from sqlite3_log()
     (row       . 100) ; sqlite3_step() has another row ready
     (done      . 101) ; sqlite3_step() has finished executing
     ))

 (define (number->sqlite3:status status)
   (let ([x (find (lambda (a) (equal? (cdr a) status)) sqlite3:status)])
     (if (pair? x) (car x) #f)))

 (define sqlite3:type-enum (make-enumeration '(undefined integer float text blob null)))
 (define sqlite3:type-index (enum-set-indexer sqlite3:type-enum))
 (define (sqlite3:type-ref index)
   (list-ref (enum-set->list sqlite3:type-enum) index))

 ;; Auxiliary types

 (define-ftype sqlite3:context void*)

 (define-ftype sqlite3:value void*)

 ;; Types for databases and statements

 (define-ftype sqlite3:database* void*)

 (define-ftype sqlite3:database** (* sqlite3:database*))
                                        ;(define-check+error-type database)
 (define-ftype sqlite3:statement* void*)
 (define-ftype sqlite3:statement** (* sqlite3:statement*))

 (define-record-type (&sqlite3 make-sqlite3-condition $sqlite3-condition?)
   (parent &condition)
   (fields (immutable status $sqlite3-condition-status)))

 (define-record-type database
   (fields
    (mutable ptr)
    (mutable busy-handler)))

 (define-record-type statement
   (fields
    (mutable ptr)
    (mutable database)))

                                        ;(record-writer
                                        ; (type-descriptor statement)
                                        ; (lambda (r p wr)
                                        ;   (wr
                                        ;    (if (statement-ptr r)
                                        ;        (format "#<sqlite3:statement sql=~s>" (source-sql r))
                                        ;        "#<sqlite3:statement zombie>")
                                        ;    p)))

                                        ;(define-check+error-type statement)

;;; Helpers

 ;; Conditions
 (define rtd (record-type-descriptor &sqlite3))
 (define sqlite3-condition? (condition-predicate rtd))
 (define sqlite3-status (condition-accessor rtd $sqlite3-condition-status))

 (define (make-sqlite3-error-condition loc msg sta . args)
   (condition
    (make-sqlite3-condition sta)
    (make-who-condition loc)
    (make-message-condition msg)
    (make-irritants-condition args)
    ))

 (define (make-no-data-condition loc stmt params)
   (make-sqlite3-error-condition loc
                                 "the statement returned no data"
                                 'done
                                 stmt params))

 ;; Errors
 (define (abort-sqlite3-error loc db . args)
   (lambda (sta)
     (if (not (equal? sta 0))
         (raise
          (apply make-sqlite3-error-condition
                 loc
                 (if db (sqlite3-errmsg db) "sta")
                 sta
                 args)))))

 (define (print-error-message obj port str)
   (display obj port) (display str port) (newline port))

 (define (print-error msg obj)
   (print-error-message obj (current-error-port) (string-append "Error: " msg)))

;;; Database interface

 ;; Get any error message
 (define sqlite3_errmsg
   (foreign-procedure "sqlite3_errmsg" (sqlite3:database*) string))
 (define (sqlite3-errmsg db)
   (check-database 'sqlite3-errmsg db)
   (sqlite3_errmsg (database-addr db)))

 ;; Open a database
 (define (open-database path)
   (assert (and open-database (string? path)))
   (let* ([ptr (make-ftype-pointer sqlite3:database**
                                   (foreign-alloc (ftype-sizeof sqlite3:database**)))]
          [f (foreign-procedure "sqlite3_open" (string void*) int)]
          [e (f path (ftype-pointer-address ptr))])
     (if (< e 0)
         (abort-sqlite3-error 'open-database #f path)
         (make-database (ftype-&ref sqlite3:database** (*) ptr) #f))))

 (define (check-database context db)
   (assert (and context (database? db))))

 (define (check-statement context db)
   (assert (and context (statement? db))))

 ;; Set application busy handler.  Does not use a callback, so it is safe
 ;; to yield.  Handler is called with DB, COUNT and LAST (the last value
 ;; it returned).  Return true value to continue trying, or #f to stop.
 (define (set-busy-handler! db handler)
   (check-database 'set-busy-handler! db)
   (database-busy-handler-set! db handler))

 (define (database-addr db)
   (ftype-pointer-address (database-ptr db)))

 (define (statement-addr stmt)
   (ftype-pointer-address (statement-ptr stmt)))

 ;; Cancel any running database operation as soon as possible
 (define (interrupt! db)
   (check-database 'interrupt! db)
   (let ([f (foreign-procedure "sqlite3_interrupt" (sqlite3:database*) void)])
     (f (database-addr db))))

 ;; Check whether the database is in autocommit mode
 (define (auto-committing? db)
   (check-database 'auto-committing? db)
   (let ([f (foreign-procedure "sqlite3_get_autocommit" (sqlite3:database*) boolean)])
     (f (database-addr db))))

 ;; Get the number of changes made to the database
 (define change-count
   (case-lambda
     [(db) (change-count db #f)]
     [(db total)
      (check-database 'change-count db)
      (let ([total-changes (foreign-procedure "sqlite3_total_changes" (sqlite3:database*) int)]
            [changes (foreign-procedure "sqlite3_changes" (sqlite3:database*) int)])
        (if total
            (total-changes (database-addr db))
            (changes (database-addr db))))]))

 ;; Get the row ID of the last inserted row
 (define (last-insert-rowid db)
   (check-database 'last-insert-rowid db)
   (let ([f (foreign-procedure "sqlite3_last_insert_rowid" (sqlite3:database*) int)])
     (f (database-addr db))))

 ;; Close a database or statement handle
 (define (sqlite3-finalize db)
   (check-database 'sqlite3-finalize db)
   (let* ([f (foreign-procedure "sqlite3_finalize"  (sqlite3:database*) int)]
          [n (f (database-addr db))])
     (database-ptr-set! db #f)
     n))

 (define (sqlite3-next-stmt db)
   (check-database 'sqlite3-next-stmt db)
   (let* ([f (foreign-procedure "sqlite3_next_stmt" (sqlite3:database*) sqlite3:statement*)]
          [stmt* (f (database-addr db))])
     (make-statement (make-ftype-pointer sqlite3:statement* stmt*)
                     db)))

 (define finalize!
   (case-lambda
    [(x)
     (finalize! x #f)]
    [(x finalize-statements?)
     (define sqlite3_finalize (foreign-procedure "sqlite3_finalize" (sqlite3:statement*) int))
     (cond
      [(database? x)
       (cond
	[(not (database-ptr x))
	 (void)]
	[(let loop ([stmt
		     (and
		      finalize-statements?
		      (sqlite3-next-stmt x))])
	   (if stmt
	       (or (sqlite3_finalize (statement-addr x))
		   (loop (sqlite3-next-stmt (statement-database x))))
	       (let ([f (foreign-procedure "sqlite3_close" (sqlite3:database*) int)])
		 (f (database-addr x)))))
	 => (abort-sqlite3-error 'finalize! x x)])]
      [(statement? x)
       (cond
	[(not (statement-ptr x))
	 (void)]
	[ (sqlite3_finalize (statement-addr x))
	  => (abort-sqlite3-error 'finalize! (statement-database x) x)]
	[else
	 (statement-ptr-set! x #f)])]
      [else
       (errorf 'finalize! "database or statement ~d" x)])]))
     ;; #;(define finalize!
 ;;   (match-lambda*
 ;;    [((? database? db) . finalize-statements?)
 ;;      (cond
 ;;       [(not (database-ptr db))
 ;;       (void)]
 ;;       [(let loop ([stmt
 ;;                   (and
 ;;                     (optional finalize-statements? #f)
 ;;                     (sqlite3_next_stmt db #f))])
 ;;          (if stmt
 ;;              (or (sqlite3_finalize stmt) (loop (sqlite3_next_stmt db stmt)))
 ;;              ((foreign-safe-lambda sqlite3:status "sqlite3_close" sqlite3:database) db)))
 ;;       => (abort-sqlite3-error 'finalize! db db)]
 ;;       [else
 ;;       (let ([id (pointer->address (database-ptr db))]
 ;;             [release-qns (lambda (_ info) (object-release (vector-ref info 0)))])
 ;;         (call-with/synch *collations*
 ;;                           (cute hash-table-tree-clear! <> id release-qns))
 ;;         (call-with/synch *functions*
 ;;                           (cute hash-table-tree-clear! <> id release-qns))
 ;;         (database-ptr-set! db #f)
 ;;         (database-busy-handler-set! db #f))])]
 ;;    [((? statement? stmt))
 ;;      (cond
 ;;       [(not (statement-ptr stmt))
 ;;       (void)]
 ;;       [(sqlite3_finalize (statement-ptr stmt))
 ;;       => (abort-sqlite3-error 'finalize! (statement-database stmt) stmt)]
 ;;       [else
 ;;       (statement-ptr-set! stmt #f)])]
 ;;    [(v . _)
 ;;      (error-argument-type 'finalize! v "database or statement")]))

;;; Statement interface
 (define sqlite3_prepare_v2 (foreign-procedure "sqlite3_prepare_v2"
                                               ( sqlite3:database* u8* int void* u8*) int))
 (define (alloc-statement*)
   (make-ftype-pointer sqlite3:statement**
                       (foreign-alloc (ftype-sizeof sqlite3:statement**))))

 ;; Create a new statement
 (define (prepare db sql)
   (check-database 'prepare db)
   (assert (and prepare (string? sql)))
   (let retry ([retries 0])
     (let* ([ptr (alloc-statement*)]
            [zSql (string->utf8 sql)]
            [nByte (bytevector-length zSql)]
            [e (sqlite3_prepare_v2 (database-addr db) zSql nByte (ftype-pointer-address ptr) #f)])
       (cond [(equal? e 0)
              (make-statement (ftype-&ref sqlite3:statement** (*) ptr) db)]
             [else
              (case (number->sqlite3:status e)
                [(busy)
                 (let ([h (database-busy-handler db)])
                   (cond
                    [(and h (h db retries))
                     (retry (fx+ retries 1))]
                    [else
                     ((abort-sqlite3-error 'prepare db db sql) e)]))]
                [else
                 ((abort-sqlite3-error 'prepare db db sql) e)])]))))

 ;; Retrieve the SQL source code of a statement
 (define (source-sql stmt)
   (check-statement 'source-sql stmt)
   (let* ([f (foreign-procedure "sqlite3_sql" (sqlite3:statement*) string)])
     (f (statement-addr stmt))))

 (define (finalize-statement! stmt)
   (check-statement 'finalize-statement! stmt)
   (let* ([f (foreign-procedure "sqlite3_finalize"  (sqlite3:statement*) int)]
          [n (f (statement-addr stmt))])
     (statement-ptr-set! stmt #f)
     n))

 ;; Reset an existing statement to process it again
 (define (reset! stmt)
   (check-statement 'reset! stmt)
   (cond [((foreign-procedure  "sqlite3_reset" (sqlite3:statement*) int)
           (statement-addr stmt))
          => (abort-sqlite3-error 'reset! (statement-database stmt) stmt)]))

 ;; Get number of bindable parameters
 (define (bind-parameter-count stmt)
   (check-statement 'bind-parameter-count stmt)
   ((foreign-procedure "sqlite3_bind_parameter_count" (sqlite3:statement*) int)
    (statement-addr stmt)))

 ;; Get index of a bindable parameter or #f if no parameter with the
 ;; given name exists
 (define (bind-parameter-index stmt name)
   (check-statement 'bind-parameter-index stmt)
   (let ([i ((foreign-procedure "sqlite3_bind_parameter_index"
                                (sqlite3:statement* string) int)
             (statement-addr stmt) name)])
     (if (zero? i)
         #f
         (fx- i 1))))

 ;; Get the name of a bindable parameter
 (define (bind-parameter-name stmt i)
   (check-statement 'bind-parameter-name stmt)
   ((foreign-procedure "sqlite3_bind_parameter_name" (sqlite3:statement* int) string)
    (statement-addr stmt) (fx+ i 1)))

 ;; Bind data as parameters to an existing statement

 (define SQLITE_TRANSIENT -1)
 (define (bind! stmt i v)
   (check-statement 'bind! stmt)
   (assert (and bind! (number? i) (>= i 0)))
   (cond
    [(bytevector? v)
     (cond [((foreign-procedure "sqlite3_bind_blob" (sqlite3:statement* int u8* int void*) int)
             (statement-addr stmt) (fx+ i 1) v (bytevector-length v) SQLITE_TRANSIENT)
            => (abort-sqlite3-error 'bind! (statement-database stmt) stmt i v)])]
    [(or (and (fixnum? v) v) (and (boolean? v) (if v 1 0)))
     => (lambda (v)
          (cond [((foreign-procedure "sqlite3_bind_int"
                                     (sqlite3:statement* int int) int)
                  (statement-addr stmt) (fx+ i 1) v)
                 => (abort-sqlite3-error 'bind! (statement-database stmt) stmt i v)]))]
    [(real? v)
     (cond [((foreign-procedure "sqlite3_bind_double"
                                (sqlite3:statement* int double) int)
             (statement-addr stmt) (fx+ i 1) (exact->inexact v))
            => (abort-sqlite3-error 'bind! (statement-database stmt) stmt i v)])]
    [(string? v)
     (let ([f (foreign-procedure "sqlite3_bind_text"
                                 (sqlite3:statement* int u8* int void*) int)]
           [s (string->utf8 v)])
       (cond [(f (statement-addr stmt) (fx+ i 1) s (bytevector-length s) SQLITE_TRANSIENT)
              => (abort-sqlite3-error 'bind! (statement-database stmt) stmt i v)]))]
    [(sql-null? v)
     (cond [((foreign-procedure "sqlite3_bind_null" (sqlite3:statement* int) int)
             (statement-addr stmt) (fx+ i 1))
            => (abort-sqlite3-error 'bind! (statement-database stmt) stmt i)])]
    [else
     (error 'bind! "blob, number, boolean, string or sql-null" v)]))

                                        ; Helper

 (define (%bind-parameters! loc stmt params)
   (reset! stmt)
   (let ([cnt (bind-parameter-count stmt)]
         [vs (make-eq-hashtable)])
     (let loop ([i 0] [params params])
       (match params
         [((? symbol? k) v . rest)
          (cond
           [(bind-parameter-index stmt (string-append ":" (symbol->string k)))
            => (lambda (j)
                 (hashtable-set! vs j v)
                 (loop i rest))]
           [else
            (error loc "value or keyword matching a bind parameter name" k)])]
         [(v . rest)
          (hashtable-set! vs i v)
          (loop (fx+ i 1) rest)]
         [()
          (void)]))
     (if (= (hashtable-size vs) cnt)
         (unless (zero? cnt)
           (hashtable-walk vs (cut bind! stmt <> <>)))
         (raise
          (condition
           (make-who-condition loc)
           (make-message-condition (conc "bad parameter count - received " (hashtable-size vs) " but expected " cnt))
           (make-sqlite3-condition 'error))))))

 (define (bind-parameters! stmt . params)
   (%bind-parameters! 'bind-parameters! stmt params))

 ;; Single-step a prepared statement, return #t if data is available,
 ;; #f otherwise
 (define (step! stmt)
   (check-statement 'step! stmt)
   (let ([db (statement-database stmt)])
     (let retry ([retries 0])
       (let ([s ((foreign-procedure
                  "sqlite3_step" (sqlite3:statement*) int) (statement-addr stmt))])
         (case (number->sqlite3:status s)
           [(row)
            #t]
           [(done)
            #f]
           [(busy)
            (let ([h (database-busy-handler db)])
              (cond
               [(and h (h db retries))
                (retry (fx+ retries 1))]
               [else
                ((abort-sqlite3-error 'step! db stmt) s)]))]
           [else
            ((abort-sqlite3-error 'step! db stmt) s)])))))

 ;; Retrieve information from a prepared/stepped statement
 (define (column-count stmt)
   (check-statement 'column-count stmt)
   ((foreign-procedure "sqlite3_column_count" (sqlite3:statement*) int) (statement-addr stmt)))

 (define (column-type stmt i)
   (check-statement 'column-type stmt)
   (sqlite3:type-ref ((foreign-procedure  "sqlite3_column_type" (sqlite3:statement* int) int) (statement-addr stmt) i)))

 (define (column-declared-type stmt i)
   (check-statement 'column-declared-type stmt)
   ((foreign-procedure "sqlite3_column_decltype" (sqlite3:statement* int) string) (statement-addr stmt) i))

 (define (column-name stmt i)
   (check-statement 'column-name stmt)
   ((foreign-procedure "sqlite3_column_name" (sqlite3:statement* int) string) (statement-addr stmt) i))

 (define sqlite3_column_double
   (foreign-procedure "sqlite3_column_double" (sqlite3:statement* int) double))

 (define sqlite3_column_int64
   (foreign-procedure "sqlite3_column_int64" (sqlite3:statement* int) integer-64))

 (define sqlite3_column_boolean
   (foreign-procedure "sqlite3_column_int" (sqlite3:statement* int) boolean))

 (define (sqlite3-column-bytes stmt i)
   ((foreign-procedure "sqlite3_column_bytes" (sqlite3:statement* int) int)
    (statement-addr stmt) i))

 (define (void*->bytevector ptr len)
   (define-ftype byte-array (array 0 unsigned-8))
   (let ([arr (make-ftype-pointer byte-array ptr)]
         [bv  (make-bytevector len)])
     (let loop ((i 0))
       (when (< i len)
         (bytevector-u8-set! bv i (ftype-ref byte-array (i) arr))
         (loop (fx+ 1 i))))
     bv))

 (define (void*->string ptr len)
   (utf8->string (void*->bytevector ptr len)))

 (define (sqlite3-column-text stmt i)
   (let* ([ptr ((foreign-procedure "sqlite3_column_text" (sqlite3:statement* int) void*)
                (statement-addr stmt) i)]
          [len (sqlite3-column-bytes stmt i)])
     (void*->string ptr len)))

 (define (sqlite3-column-blob stmt i)
   (let* ([ptr ((foreign-procedure "sqlite3_column_blob" (sqlite3:statement* int) void*)
                (statement-addr stmt) i)]
          [len (sqlite3-column-bytes stmt i)])
     (void*->bytevector ptr len)))

 ;; Retrieve data from a stepped statement
 (define (column-data stmt i)
   (case (column-type stmt i)
     [(integer)
      (if (and-let* ([type (column-declared-type stmt i)])
                    (string-contains-ci type "bool"))
          (sqlite3_column_boolean (statement-addr stmt) i)
          (sqlite3_column_int64 (statement-addr stmt) i))]
     [(float)
      (sqlite3_column_double (statement-addr stmt) i)]
     [(text)
      (sqlite3-column-text stmt i)]
     [(blob)
      (sqlite3-column-blob stmt i)]
     [else
      (sql-null)]))

;;; Easy statement interface

 ;; Compile a statement and call a procedure on it, then finalize the
 ;; statement in a dynamic-wind exit block if it hasn't been finalized yet.
 (define (call-with-temporary-statements proc db . sqls)
   (check-database 'call-with-temporary-statements db)
   (let ([stmts #f] [exn #f])
     (dynamic-wind
       (lambda ()
         (unless stmts
           (set! stmts (map (cute prepare db <>) sqls))))
       (lambda ()
         (guard (e [else (set! exn e)])
                (apply proc stmts)))
       (lambda ()
         (and-let* ([s stmts])
                   (set! stmts #f)
                   (for-each finalize! s)) ;; leaks if error occurs before last stmt
         (and-let* ([e exn])
                   (set! exn #f)
                   (raise e))))))

 (define-syntax %define/statement+params
   (syntax-rules ()
     [(%define/statement+params ((name loc) (init ...) (stmt params))
                                body ...)
      (define name
        (let ([impl (lambda (init ... stmt params) body ...)])
          (lambda (init ... db-or-stmt . params)
            (cond
             [(database? db-or-stmt)
              (call-with-temporary-statements
               (cute impl init ... <> (cdr params))
               db-or-stmt (car params))]
             [(statement? db-or-stmt)
              (impl init ... db-or-stmt params)]
             [else
              (error loc "database or statement" db-or-stmt)]))))]
     [(%define/statement+params (name (init ...) (stmt params))
                                body ...)
      (%define/statement+params ((name 'name) (init ...) (stmt params))
                                body ...)]
     [(%define/statement+params (name stmt params)
                                body ...)
      (%define/statement+params ((name 'name) () (stmt params))
                                body ...)]))

                                        ; from chicken miscmacros.scm
 (define-syntax while
   (syntax-rules ()
     ((while test body ...)
      (let loop ()
        (if test
            (begin
              body ...
              (loop)))))))

 ;; Step through a statement and ignore possible results
 (define (%execute loc stmt params)
   (%bind-parameters! loc stmt params)
   (while (step! stmt))
   (void))

 (%define/statement+params (execute stmt params)
                           (%execute 'execute stmt params))

 ;; Step through a statement, ignore possible results and return the
 ;; count of changes performed by this statement
 (%define/statement+params (update stmt params)
                           (%execute 'update stmt params)
                           (change-count (statement-database stmt)))

 ;; Return only the first column of the first result row produced by this
 ;; statement

 (%define/statement+params (first-result stmt params)
                           (%bind-parameters! 'first-result stmt params)
                           (if (step! stmt)
                               (let ([r (column-data stmt 0)])
                                 (reset! stmt)
                                 r)
                               (raise (make-no-data-condition 'first-result stmt params))))

 ;; Return only the first result row produced by this statement as a list

 (%define/statement+params (first-row stmt params)
                           (%bind-parameters! 'first-row stmt params)
                           (if (step! stmt)
                               (map (cute column-data stmt <>)
                                    (iota (column-count stmt)))
                               (raise (make-no-data-condition 'first-row stmt params))))

 ;; Apply a procedure to the values of the result columns for each result row
 ;; while executing the statement and accumulating results.

 (%define/statement+params ((%fold-row loc) (loc proc init) (stmt params))
                           (%bind-parameters! loc stmt params)
                           (let ([cl (iota (column-count stmt))])
                             (let loop ([acc init])
                               (if (step! stmt)
                                   (loop (apply proc acc (map (cute column-data stmt <>) cl)))
                                   acc))))

 (define-syntax check-procedure
   (syntax-rules ()
     [(_ loc proc)
      (assert (and loc (procedure? proc)))]))

 (define (fold-row proc init db-or-stmt . params)
   (apply %fold-row 'fold-row proc init db-or-stmt params))

 ;; Apply a procedure to the values of the result columns for each result row
 ;; while executing the statement and discard the results

 (define (for-each-row proc db-or-stmt . params)
   (check-procedure fold-row proc)
   (apply %fold-row
          'for-each-row
          (lambda (acc . columns)
            (apply proc columns))
          (void)
          db-or-stmt params))

 ;; Apply a procedure to the values of the result columns for each result row
 ;; while executing the statement and accumulate the results in a list

 (define (map-row proc db-or-stmt . params)
   (check-procedure 'map-row proc)
   (reverse!
    (apply %fold-row
           'map-row
           (lambda (acc . columns)
             (cons (apply proc columns) acc))
           '()
           db-or-stmt params)))

;;; Utility procedures

 ;; Run a thunk within a database transaction, commit if return value is
 ;; true, rollback if return value is false or the thunk is interrupted by
 ;; an exception
 (define with-transaction
   (case-lambda
     ((db thunk) (with-transaction db thunk 'deferred))
     ((db thunk type)
      (check-database 'with-transaction db)
      (check-procedure 'with-transaction thunk)
      (unless (memq type '(deferred immediate exclusive))
        (error 'with-transaction  "bad argument: expected deferred, immediate or exclusive")
        type)
      (let ([success? #f] [exn #f])
        (dynamic-wind
          (lambda ()
            (execute db
                     (string-append "BEGIN " (symbol->string type) " TRANSACTION;")))
          (lambda ()
            (guard (e [else (begin
                              (print-error "with-transaction" exn)
                              (set! exn e))])
                   (set! success? (thunk))
                   success?))
          (lambda ()
            (execute db
                     (if success?
                         "COMMIT TRANSACTION;"
                         "ROLLBACK TRANSACTION;"))
            (and-let* ([e exn])
                      (set! exn #f)
                      (raise e))))))))

 ;; Check if the given string is a valid SQL statement
 (define sql-complete?
   (foreign-procedure "sqlite3_complete" (string) boolean))

 ;; Return a descriptive version string
 (define database-version
   (foreign-procedure "sqlite3_libversion" () string))

 ;; Return the amount of memory currently allocated by the database
 (define database-memory-used
   (foreign-procedure "sqlite3_memory_used" () int))

 ;; Return the maximum amount of memory allocated by the database since
 ;; the counter was last reset
 (define database-memory-highwater
   (case-lambda
     (() (database-memory-highwater #f))
     ((reset?) ((foreign-procedure "sqlite3_memory_highwater" (boolean) int) reset?))))

 ;; Enables (disables) the sharing of the database cache and schema data
 ;; structures between connections to the same database.
 (define (enable-shared-cache! enable?)
   (cond-expand
    [disable-shared-cache
     #f]
    [else
     (cond
      [((foreign-procedure "sqlite3_enable_shared_cache" (boolean) int) enable?)
       => (abort-sqlite3-error 'enable-shared-cache! #f)]
      [else
       enable?])]))

 ;; Enables (disables) the loading of native extensions using SQL statements.
 (define (enable-load-extension! db enable?)
   (cond-expand
    [disable-load-extension
     #f]
    [else
     (cond
      [((foreign-procedure "sqlite3_enable_load_extension" (sqlite3:database* boolean) int) (database-addr db) enable?)
       => (abort-sqlite3-error 'enable-load-extension! db)]
      [else
       enable?])]))

 (record-writer
  (type-descriptor database)
  (lambda (r p wr)
    (wr
     (if (database-ptr r)
         "#<sqlite3:database>"
         "#<sqlite3:database zombie>")
     p)))

 ) ; library sqlite3

