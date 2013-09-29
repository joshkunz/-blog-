#lang racket

(provide exp->string)

; prefix on attribute elements
(define *attr-regex* #rx"^@(.+)")
; symbol that is the car item in an unquoted
; string pair
(define *unquote-symbol* '~uq)

(define (string-translate what table)
 (list->string
  (list-translate (string->list what) table)
 )
)

; Given the assoc table 'table' with
; character mappings, iterate through
; the string and if a mapped character is found
; replace it with the mapping.
(define (list-translate what table)
 (if (empty? what) '() ; if we've processed all characters
  (let ([mapping (assoc (car what) table)])
   (cond
    (mapping 
     (append 
      (string->list (cadr mapping))
      (list-translate (cdr what) table)))
    (#t (cons
        (car what) 
        (list-translate (cdr what) table)))
    )
  )
 )
)

; XML special character escape mappings
(define xml-escapes
 '((#\< "&lt;")
   (#\> "&gt;")
   (#\& "&amp;")
  )
)

; special character escape mappings for attributes
(define xml-attr-escapes
 '((#\< "&lt;")
   (#\> "&gt;")
   (#\& "&amp;")
   (#\" "&quot;")
  )
)

; translate out xml-escape characters
(define (xml-quote str)
 (string-translate str xml-escapes))

; Translate out xml attribute escapes
(define (xml-attr-quote str)
 (string-translate str xml-attr-escapes))

; Make an indent given the indent level
(define (tab level [spaces 4]) (make-string (* spaces level) #\ ))

; Check if a pair is an unquoted string pair

; Attributes are in the form: @attr-name
; For example: @class
(define (attr? node)
 (and (symbol? node) 
      (regexp-match? *attr-regex* (symbol->string node))
 )
)

; Check if the car element in a list
; is an attr symbol
(define (attr-pair? node)
 (and (list? node) (attr? (car node))))

; Check if this is an unquoted string
(define (unquoted-string? str-pair)
 (if (list? str-pair)
  (symbol=? (car str-pair) *unquote-symbol*)
  #f
 )
)

; Get the string name of the symbol
; without the leading @ symbol
(define (attr-name symbol)
 (cadr 
  (regexp-match *attr-regex* (symbol->string symbol))
 )
)

; Convert an attribute pair to a string
; (@attr-name "blue green") => attr-name="blue green"
(define (attr-pair-string pair)
 (string-append 
  " " (attr-name (car pair)) 
  "=\"" (xml-attr-quote (cadr pair)) "\""
 )
)

; Generate the 'opening' part of an xml tag
(define (open-tag symbol)
 (string-append "<" (symbol->string symbol)))

; Cap off a tag if it hasn't been closed
(define (cap-close closed? newline?)
 (if closed? "" 
  (string-append ">" (if newline? "\n" ""))
 )
)

; Closer that evaluates to the null string
(define (null-closer parent indent) "")

; Closer that writes an empty-element closing
(define (empty-closer symbol indent) "/>\n")

(define (empty-tag-closer symbol indent) 
 (string-append "></" (symbol->string symbol) ">\n")
)

; Closer that writes a full </tag-name> closure
(define (tag-closer symbol indent)
 (if symbol 
  (string-append (tab indent) "</" (symbol->string symbol) ">\n") 
  ""
 )
)

; Helper function for the internal converter iexp->string
(define (exp->string document (use-empty? #t))
 (cond
  ; If we are given an empty document
  ([empty? document] '())
  ; If we are given a bare string
  ([string? document] (xml-quote document))
  ; If we are given an unquoted string
  ([unquoted-string? document] (cadr document))
  ; Otherwise, we have a real tree
  (#t (iexp->string document '() #f use-empty?))
 )
)

(define (iexp->string xp parent closed? use-empty?
                      (closer null-closer) 
                      (indent 0))
 (cond
  ; If we're at the end of this sub-tree
  ([empty? xp]
   (closer parent indent)
  )
  ; If this element is a string
  ([string? (car xp)] 
   (string-append
    (cap-close closed? #f) 
    (xml-quote (car xp))
    (iexp->string (cdr xp) parent #t use-empty? tag-closer 0)
   )
  )
  ; If this element is an unquoted string
  ((unquoted-string? (car xp))
   (string-append
    (cap-close closed? #f)
    (cadr (car xp))
    (iexp->string (cdr xp) parent #t use-empty? tag-closer 0)
   )
  )
  ; If this element is the start of a new XML element
  ((symbol? (car xp)) 
   (let ([w-closer (if use-empty? empty-closer empty-tag-closer)])
    (string-append
     (closer parent indent)
     (tab indent) (open-tag (car xp))
     (iexp->string (cdr xp) (car xp) #f use-empty? w-closer indent)
    )
   )
  )
  ; If we have an attribute pair for this element
  ((attr-pair? (car xp))
   (string-append 
    (attr-pair-string (car xp))
    (iexp->string (cdr xp) parent closed? use-empty? closer indent)
   )
  )
  ; If we're starting a new sub-tree
  ((list? (car xp))
   (string-append 
    (cap-close closed? #t)
    ; Follow the tree down
    (iexp->string (car xp) parent #t use-empty? null-closer (+ indent 1))
    ; then parse the next element
    (iexp->string (cdr xp) parent #t use-empty? tag-closer indent)
   )
  )
 )
)
