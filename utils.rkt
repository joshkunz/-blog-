#lang racket

(require racket/date)

(provide (contract-out
    [minimum-post? (-> any/c boolean?)]
    [post-title (-> minimum-post? string?)]
    [post-content (-> minimum-post? any/c)]
    [post-date (-> minimum-post? date?)]
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
        (assoc 'content possible-post)
        (assoc 'date possible-post)))
  (#t #f)
 )
)

(define (post-get what post)
 (cadr (assoc what post))
)

; Post getters
(define (post-title post) (post-get 'title post))
(define (post-content post) (post-get 'content post))
(define (post-date post) (post-get 'date post))
