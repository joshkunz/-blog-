; General OS related utilities
(context 'os)

; Import tmpnam from libc
(set 'libc-name (case ostype
                 ("OSX" "libc.dylib"))
)

(import libc-name "tmpnam" "char*" "char*")

; newLISP wrapper for C's tmpnam
(define (tempname)
 (get-string (tmpnam 0))
)

; Utilities for blog generation
(context 'rss)

(set '*generator* "newLISP RSS v0.1")

; Date formatting string for the rss spec
(set 'rss-date_f "%a, %d %b %Y %H:%M:%S GMT")

(define (rss-date (date-int (apply date-value (now))))
 (date date-int 0 rss-date_f)
)

; _title -> title of the channel
; _link -> link to the channel
; _desc -> description of the channel
; _lang -> language of the channel
; _build -> last date of the build
(set 'channel_f
 (letex (_generator *generator*)
 '(channel
   (title _title)
   (link _link)
   (description _desc)
   (language _lang)
   (lastBuildDate _build)
   (generator _generator)
   ; _items
  )
 )
)

; _title -> title of the item
; _author -> author of the item
; _link -> fully-qalified link to the item
; _date -> date the item was published
; _desc -> description of the item
(set 'item_f
 '(item
   (title _title)
   (author _author)
   (link _link)
   (pubDate _date)
   (description _desc)
   (guid _link)
  )
)

; Function for generating a feed
(define (feed _channels (_version "2.0"))
 (extend 
  (expand '(rss (@version _version)) '_version) _channels)
)

(define (channel _title 
                 _link 
                 _desc
                 _items
                 (_lang "en-us")
                 (_build (rss-date)))

 (extend 
  (expand channel_f
   '_title '_link '_desc '_lang '_build)
  _items)
)

(define (item _title 
              _author
              _link
              _date
              _desc)
 (expand item_f
  '_title '_author '_link '_date '_desc)
)

; A FOOP for blogs
(context 'blog)

; Markdown a piece of raw text
(define (markdown text)
 (letn (tname (os:tempname)
        tfile (open tname "write"))
  (write tfile text)
  (close tfile)
  (join (exec (append "markdown " tname)))
 )
)

(set '*posts* '())
(set '*title* "")
(set '*author* "")
(set '*link-base* "")

(set '*date-format* "%Y-%m-%d")

(set '*post_f*
 '((title _title)
   (posted _posted)
   (path _path)
   (content _content)
  )
)

; Get the last item from a assoc lookup
(define (assoc-get expr from)
 (last (assoc expr from)))


; Parse a date-string with the date-format
(define (on date-string)
 (date-list
  (date-parse date-string *date-format*)
 )
)

; Storting functor that check the difference
; between dates
(define (date-desc postA postB)
 (> 
  (assoc-get 'posted postA) 
  (assoc-get 'posted postB)
 )
)

(define (date-asc postA postB)
 (<
  (assoc-get 'posted postA)
  (assoc-get 'posted postB)
 )
)

; Add a new post to the posts list
(define (post _title _posted _path _content)
 (let (this-post 
       (expand *post_f* 
        '_title '_posted '_path '_content))
  (setq *posts* (cons this-post *posts*))
 )
)

; Join two url parts
(define (url-join partA partB)
 (let (f-partA (if (= (last partA) "/") (chop partA) partA)
       f-partB (if (= (first partB) "/") (rest partB) partB))
  (join (list f-partA f-partB) "/")
 )
)

; Convert a post into an rss-item 
(define (post-as-item post)
 (rss:item
  (assoc-get 'title post)
  *author*
  (url-join *link-base* (assoc-get 'path post))
  (rss:rss-date (apply date-value (assoc-get 'posted post)))
  (assoc-get 'content post)
 )
)
  
; Render this blog as an rss-feed
(define (render-rss desc)
 (rss:feed
  (list 
  (rss:channel
   *title*
   *link-base*
   desc
   (map post-as-item *posts*)
  )
  )
 )
)

(context 'MAIN)
