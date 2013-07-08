(load "xml.lsp")

(print
(XML:sdump
 '(html
   (body
    (div (~uq "<h1> Some raw text</h1>"))
   )
  )
)
)

(exit)
