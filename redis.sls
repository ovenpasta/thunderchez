
(library
    (redis)
  (export return-redis-closure redis-init
  )

  (import (chezscheme)
          (only (srfi s1 lists) take drop first)
          (posix)
          (socket))

  (include "redis/main.scm")

  (define (redis-init)
    (load-shared-object "libc.so.6")))

