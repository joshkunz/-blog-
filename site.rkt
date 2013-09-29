#lang racket 

(provide (contract-out
    [out-file (-> string? string? void?)]
))

; Dump the string contents to the given files
(define (out-file file-contents file-path) 
 (let ([output-file 
        (open-output-file file-path #:exists 'truncate/replace)])
  (write-string file-contents output-file)
  (close-output-port output-file)
 )
)
