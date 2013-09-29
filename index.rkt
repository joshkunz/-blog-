#lang racket

(provide index)

(require "xml.rkt")
(require "utils.rkt")

(require srfi/19)

(define (post->expr post)
 `(div [@class "post"]
   (h1 [@class "title"] 
    ,(post-title post))
   (span [@class "date"]
    ,(date->string (post-date post) "~Y~m~d"))
   (div [@class "content"]
    ,(post-content post)
   )
  )
)


(define (index posts)
 (let ([document
  `(html
     (head
      ; 960.gs css files
      (link [@type "text/css"] [@rel "stylesheet"] [@href "css/reset.css"])
      (link [@type "text/css"] [@rel "stylesheet"] [@href "css/text.css"])
      (link [@type "text/css"] [@rel "stylesheet"] [@href "css/960.css"])
      ; 'Colorful' Pygmentize theme
      (link [@type "text/css"] [@rel "stylesheet"] [@href "css/colorful.css"])
      ; My personal CSS file
      (link [@type "text/css"] [@rel "stylesheet"] [@href "css/personal.css"])
     )
     (body
      ,(foldr cons 
        (map post->expr posts) 
        '(div [@class "container_12"]
          (a [@class "rss"] [@href "blog.rss"] "rss")
          (div [@class "clear"]))
       )
     )
   )])
  (exp->string document #f)
 )
)
