#lang racket

(require "../main.rkt")


(define handler
  (lambda (event context)
    (hash-set event 'message "Hello from Racket on Lambda!")))

(set-handler handler)

