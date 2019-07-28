#lang racket

(define handler
  (lambda (event context)
    (hash-set event 'message "Hello from Racket on Lambda!")))

(provide handler)

