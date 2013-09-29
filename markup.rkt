#lang racket

(provide (contract-out
 [wrap (-> string? list?)]
 [raw (-> string? list?)]
 [file (-> file-exists? string?)]
 [external-render (-> list? string? string?)]
 [markdown (-> string? string?)]
 [pandoc (-> string? string?)]
 [py-markdown (-> string? string?)]
 )
)

; Wrap the string content in a paragraph
(define (wrap content)
 (list 'p content)
)

; Wrap the body as an unquoted string
(define (raw content)
 (list '~uq content)
)

; Read the contents of 'filename' into a string
(define (file filename)
 (let ([file-port (open-input-file filename)])
  (begin0
   (string-trim (port->string file-port))
   (close-input-port file-port)
  )
 )
)

; Render the given string content in markdown
(define (markdown markdown-content)
 (external-render '("markdown") markdown-content)
)

; Render with pandoc
(define (pandoc markdown-content)
 (external-render '("pandoc" "-highlight-style=pygments") markdown-content)
)

; Render with python-markdown
(define (py-markdown markdown-content)
 (external-render '("python" "-m" "markdown" "-x" "extra" "-x" "codehilite") markdown-content)
)

; pass the given string into the supplied program where 'program' is a
; list where the first element is the name of the executable and 
; the following elements are arguments passed to the program
(define (external-render program content)
 (let ([program-with-path 
       (list* (find-executable-path (car program)) (cdr program)) ])
  (external-render-path program-with-path content)
 )
)

; Same as 'external-render' except that the first element of 'program'
; is a path to the program's executable instead of the name.
(define (external-render-path program content)
  ; Run the subprocess
  (let-values ([(proc-out 
                 proc-in 
                 pid 
                 proc-err 
                 control)
                (apply values (apply process* program))])
   ; Write the content to the process
   (write-string content proc-in)
   ; Close the output port (hopefully triggering an EOF)
   (close-output-port proc-in)
   (begin0
    ; Read out the formatted body
    (port->string proc-out)
    ; Close the output
    (close-input-port proc-out)
    ; Close the error
    (close-input-port proc-err)
    ; Make sure the process is dead
    (control 'kill)
   )
   ; The rendered content will be returned 
  )
)
