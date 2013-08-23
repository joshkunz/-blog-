#lang racket

(provide (contract-out
 [file (-> file-exists? string?)]
 [markdown (-> string? box?)]
 )
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

; Render a string in markdown format
(define (markdown markdown-content)
 ; Get the path to the markdown executable
 (let ([markdown-path (find-executable-path "markdown")])
  ; Run markdown as a subrocess
  (let-values ([(markdown-out 
                 markdown-in 
                 pid 
                 markdown-err 
                 control)
                (apply values (process* markdown-path))])
   ; Write the markdown content to the process
   (write-string markdown-content markdown-in)
   ; Close the output port (hopefully triggering an EOF
   (close-output-port markdown-in)
   (begin0
    ; Read out the formatted body
    (box (port->string markdown-out))
    ; Close the output
    (close-input-port markdown-out)
    ; Close the error
    (close-input-port markdown-err)
    ; Make sure the process is dead
    (control 'kill)
   )
   ; The content will be returned 
  )
 )
)
