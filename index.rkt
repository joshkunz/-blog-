#lang racket

(provide index)

(require xml)
(require "utils.rkt")

(define (post->xexpr post)
 `(div ([class "post"])
   (h1 ,(post-title post))
   ,(cond
     ([xexpr? (post-content post)]
      (post-content post))
     ([string? (post-content post)]
      (list 'p (post-content post)))
     (#t (list 'p "Invalid content type of post."))
    )
  )
)


(define (index posts)
 (display
 ;(xexpr->string
  `(html
    ,(foldr cons (map post->xexpr posts)
      '(body (h1 "my blog"))
     )
   )
 )
)
