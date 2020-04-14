#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/dispatch
         json)

(define response-json
  (lambda (json [headers (list)])
    (response/full
      200 #f
      (current-seconds) (string->bytes/utf-8 "application/json")
      headers
      (list (jsexpr->bytes json)))))

(define next
  (lambda (req)
    (response-json #hasheq((message . "Hello world!"))
                   (list (header #"Lambda-Runtime-Aws-Request-Id"
                                 #"123")))))

(define aws-response
  (lambda (req aws-request-id)
    (displayln "Success!")
    (displayln aws-request-id)
    (displayln (bytes->string/utf-8 (request-post-data/raw req)))
    (response-json #t)))

(define aws-error
  (lambda (req aws-request-id)
    (displayln "Error!")
    (displayln aws-request-id)
    (displayln (bytes->string/utf-8 (request-post-data/raw req)))
    (response-json #t)))

(define not-found
  (lambda (req)
    (response-json "URL Not Found")))


(define-values (dispatch url)
               (dispatch-rules
                 [("2018-06-01" "runtime" "invocation" "next") next]
                 [("2018-06-01" "runtime" "invocation" (string-arg) "response")
                  #:method "post"
                  aws-response]
                 [("2018-06-01" "runtime" "invocation" (string-arg) "error")
                  #:method "post"
                  aws-error]
                 [else not-found]))

(define server
  (lambda (req)
    (displayln (string-append (bytes->string/utf-8 (request-method req))
                              " : "
                              (url->string (request-uri req))))
    (dispatch req)))

(serve/servlet server
               #:port 8080
               #:launch-browser? #f
               #:servlet-regexp #rx"")

