#lang racket

(require json
         net/http-client)

(define handler (getenv "_HANDLER"))
(define task-root (getenv "LAMBDA_TASK_ROOT"))
(define runtime-url (getenv "AWS_LAMBDA_RUNTIME_API"))


(define get-file
  (lambda (handler)
    (car (string-split handler "."))))

(define get-method
  (lambda (handler)
    (string->symbol
      (car (cdr (string-split handler "."))))))

(define get-host
  (lambda (url)
    (car (string-split url ":"))))

(define get-port
  (lambda (url)
    (string->number (car (cdr (string-split url ":"))))))

(define file (get-file handler))
(define method (get-method handler))
(define host (get-host runtime-url))
(define port (get-port runtime-url))

(define make-pairs
  (lambda (str)
    (let* ([key (car (regexp-match #rx"[A-Za-z-]*:" str))]
           [val (string-replace str key "")])
      (list (string->symbol
              (string-titlecase (string-trim (string-replace key ":" ""))))
            (string-trim val)))))

(define map-headers
  (lambda (headers)
    (make-immutable-hasheq
      (map (lambda (bytes) (make-pairs (bytes->string/utf-8 bytes)))
           headers))))

(define main-function
  (dynamic-require
    (string->path
      (string-append task-root "/" file ".rkt"))
    method))

(define invocation-response
  (lambda (aws-request-id data)
    (let-values ([(status headers response-port)
                  (http-sendrecv
                    host
                    (string-append "/2018-06-01/runtime/invocation/"
                                   aws-request-id
                                   "/response")
                    #:method #"POST"
                    #:port port
                    #:data (jsexpr->string data))])
                (displayln status))))

(define invocation-error
  (lambda (err)
    (display err)))

(define next-invocation
  (lambda ()
    (let-values ([(status headers response-port)
                  (http-sendrecv host "/2018-06-01/runtime/invocation/next"
                                 #:port port)])
                (invocation-response
                  (car
                    (hash-ref (map-headers headers)
                              'Lambda-Runtime-Aws-Request-Id))
                  (main-function (read-json response-port) (make-hasheq))))))

(define main
  (lambda ()
    (next-invocation)
    (main)))

(main)

