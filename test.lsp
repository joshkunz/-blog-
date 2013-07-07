(load "xml.lsp")

(print
 (XML:sdump
  '(html 
    (head (title "Test Site"))
    (body (@class "\"Cool cats")
     (h1 "<i>Cool Site!</i>")
     (hr)
     (span "yeah!")
    )
   )
 )
)
(exit)
