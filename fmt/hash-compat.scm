
(define (make-eq?-table) (make-eq-hashtable))
(define hash-table-ref/default hashtable-ref)
(define hash-table-set! hashtable-set!)
(define hash-table-walk hash-table-for-each)
