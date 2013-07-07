; Utilities for blog generation
(load "xml.lsp")

(context 'RSS)

; _channels -> a list of 'channel_f' expressions
(set 'feed_f
 '(rss _channels))

; _title -> title of the channel
; _link -> link to the channel
; _desc -> description of the channel
; _lang -> language of the channel
; _build -> last date of the build
; _items -> A list of 'item_f' s-expressions
(set 'channel_f
 '(channel
   (title _title)
   (link _link)
   (description _desc)
   (language _lang)
   (lastBuildDate _build)
   (generator "newLISP generator")
   _items
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

; Date formatting string for the rss spec
(set 'rss-date_f "%a, %d %b %Y %H:%M:%S GMT")

; Function for generating a feed
(define (feed _channels)
 (expand feed_f '_channels))

(define (channel _title 
                 _link 
                 _desc
                 (_lang "en-us")
                 (_build (date (date-value) 0 rss-date_f)))
 (expand channel_f
  '_title '_link '_desc '_lang '_build)
)

(context 'MAIN)
