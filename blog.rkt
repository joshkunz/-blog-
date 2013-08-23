#lang racket

(require "utils.rkt")
(require "index.rkt")
(require "markup.rkt")

(define blog 
 (posts `(
  (post
   (title "hello world")
   (content ,(file "test_post.text"))
  )
  (post 
   (title "hello world 2")
   (content
    ,(markdown (file "test_post.md")))
   (tags (a b c d))
  )
 ))
)

(display (index blog))
(newline)

