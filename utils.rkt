#lang racket

(provide (contract-out
    [minimum-post? (-> any/c boolean?)]
    [post-title (-> minimum-post? string?)]
    [post-content (-> minimum-post? any/c)]
    [posts (-> (listof packed-post?) 
               (listof minimum-post?))]
    )
)

; Make sure the first item is 'post
(define (packed-post? post)
 (eq? 'post (car post))
)

; Remove the 'post' off of the record
; so that we can turn it into a simple
; assocication
(define (posts packed-posts)
 (map cdr packed-posts)
)

; Predicate that checks a list meets the
; absolute minimum for being a post:
; having a title and some content
(define (minimum-post? possible-post)
 (cond
  ([pair? possible-post]
   (and (assoc 'title possible-post)
        (assoc 'content possible-post)))
  (#t #f)
 )
)

; Gets the title of a post
(define (post-title post)
 (cadr (assoc 'title post))
)

; gets the content of a post
(define (post-content post)
 (cadr (assoc 'content post))
)
