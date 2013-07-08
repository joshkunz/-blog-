(context 'XML)

; prefix on attribute elements
(setq *attr-prefix* "@")
; symbol that is the first item in an unquoted
; string pair
(setq *unquote-symbol* '~uq)

; Given the assoc table 'table' with
; character mappings, iterate through
; the string and if a mapped character is found
; replace it with the mapping.
(define (translate what table)
 (let (mapping (assoc (first what) table))
  (cond
   ((empty? what) "")
   (mapping (append (nth 1 mapping) (translate (rest what) table)))
   (true (append (first what) (translate (rest what) table)))
  )
 )
)

; XML special character escape mappings
(set 'xml-escapes
 '(("<" "&lt;")
   (">" "&gt;")
   ("&" "&amp;")
  )
)

; special character escape mappings for attributes
(set 'xml-attr-escapes
 '(("<" "&lt;")
   (">" "&gt;")
   ("&" "&amp;")
   ("\"" "&quot;")
  )
)

; translate out xml-escape characters
(define (xml-quote str)
 (translate str xml-escapes))

; Translate out xml attribute escapes
(define (xml-attr-quote str)
 (translate str xml-attr-escapes))

; Make an indent given the indent level
(define (tab level (spaces 4)) (dup " " (* spaces level)))

; Check if a pair is an unquoted string pair

; Attributes are in the form: @attr-name
; For example: @class
(define (attr? node)
 (and (symbol? node) (starts-with (term node) *attr-prefix*)))

; Check if the first element in a list
; is an attr symbol
(define (attr-pair? node)
 (and (list? node) (attr? (first node))))

; Check if this is an unquoted string
(define (unquoted-string? str-pair)
 (if (list? str-pair)
  (let (sterm (term (first str-pair))
        uqterm (term *unquote-symbol*))
   (= sterm uqterm)
  )
 )
)

; Get the string name of the symbol
; without the leading @ symbol
(define (attr-name symbol)
 (let (str-symbol (term symbol))
  (slice str-symbol
   (+ (length *attr-prefix*)
      (find *attr-prefix* str-symbol))
  )
 )
)

; Convert an attribute pair to a string
; (@attr-name "blue green") => attr-name="blue green"
(define (attr-pair-string pair)
 (append " " (attr-name (first pair)) 
  "=\"" (xml-attr-quote (last pair)) "\""))

; Generate the 'opening' part of an xml tag
(define (open-tag symbol)
 (append "<" (term symbol)))

; Cap off a tag if it hasn't been closed
(define (cap-close closed? newline?)
 (if closed? "" (append ">" (if newline? "\n" ""))))

; Closer that evaluates to the null string
(define (null-closer) "")

; Closer that writes a full </tag-name> closure
(define (tag-closer symbol indent)
 (if symbol (append (tab indent) "</" (term symbol) ">\n") ""))

; Closer that writes an empty-element closing
(define (empty-closer) "/>\n")

(define (sdump xp parent closed?
                        (closer null-closer) 
                        (indent 0))
 (cond
  ((= xp '()) 
   (closer parent indent)
  )
  ((string? (first xp)) 
   (append
    (cap-close closed?) 
    (xml-quote (first xp))
    (sdump (rest xp) parent true tag-closer 0)
   )
  )
  ((unquoted-string? (first xp))
   (append
    (cap-close closed?)
    (last (first xp))
    (sdump (rest xp) parent true tag-closer 0)
   )
  )
  ((symbol? (first xp)) 
   (append
    (closer parent indent)
    (tab indent) (open-tag (first xp))
    (sdump (rest xp) (first xp) nil empty-closer indent)
   )
  )
  ((attr-pair? (first xp))
   (append 
    (attr-pair-string (first xp))
    (sdump (rest xp) parent closed? closer indent)
   )
  )
  ((list? (first xp))
   (append 
    (cap-close closed? true)
    (sdump (first xp) parent true null-closer (+ indent 1))
    (sdump (rest xp) parent true tag-closer indent)
   )
  )
 )
)

(context 'MAIN)
