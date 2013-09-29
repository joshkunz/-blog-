#lang racket

(provide rss)

(require "xml.rkt")
(require "utils.rkt")

(require srfi/19)

(define (date->rss date)
 (date->string date "~a, ~d ~b ~Y ~H:~M:~S GMT")
)

(define (post->item link post)
 `(item
   (title ,(post-title post))
   (link ,link)
   (pubDate ,(date->rss (post-date post)))
   (description ,(exp->string (post-content post)))
  )
)

(define (rss posts title url desc)
 (letrec ([posth (lambda (x) (post->item url x))]
          [items (map posth posts)])
  (exp->string
  `(rss [@version "2.0"]
    ,(foldr cons items
    `(channel
      (title ,title)
      (link ,url)
      (description ,desc)
      (lastBuildDate ,(date->rss (current-date)))
      (generator "Racket blog generator")
     ))
   )
  )
 )
)

