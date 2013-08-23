#lang racket

(provide index)

(require "xml.rkt")
(require "utils.rkt")

(define (post->expr post)
 `(div [@class "post"]
   (h1 ,(post-title post))
   (div [@class "post-content"]
    ,(cond
      ([box? (post-content post)]
       (list '~uq (unbox
                  (post-content post))))
      ([string? (post-content post)]
       (list 'p (post-content post)))
      (#t (list 'p "Invalid content type of post."))
     )
   )
  )
)


(define (index posts)
 (exp->string
  `(html
    ,(foldr cons (map post->expr posts)
      '(body (h1 "my blog"))
     )
   )
 )
)
