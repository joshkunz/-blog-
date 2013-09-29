#lang racket

(require "utils.rkt")
(require "index.rkt")
(require "rss.rkt")
(require "markup.rkt")
(require "site.rkt")

; Include the date-handling utilites
(require srfi/19)

(define *posts-folder* "posts/")

; Helpers
(define (md filename)
 (raw (py-markdown (file 
  (string-append *posts-folder* filename)))
 )
)

(define (iso st)
 (string->date st "~Y-~m-~d")
)

(define (status message)
 (display message) (newline)
)

; Make the blog
(define blog 
 (posts `(
  (post 
   (title "Obstack.net")
   (date ,(iso "2013-09-29"))
   (content ,(md "test_post.md"))
  )
 ))
)

; Build the index
(status "Writing blog index...")
(out-file (index blog) "./output/index.html")

; Build the feed
(status "Writing blog feed...")
(out-file (rss blog "Racket Blog" "http://me.obstack.net" "Blog") "./output/blog.rss")
