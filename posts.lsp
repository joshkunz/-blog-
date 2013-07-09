(load "blog.lsp")
(load "xml.lsp")

(new blog 'josh)

(setq josh:*title* "Josh's blog")
(setq josh:*author* "Josh Kunz")
(setq josh:*link-base* "http://joshkunz.com")

(josh:post
 "This is a post by josh"
 (josh:on "2013-07-07")
 "this-is-a-post-by-josh"
 (blog:markdown
  "This is a post that I am writing
  for fun... it will be the coolest...."
 )
)

(josh:post
 "This is another post by josh"
 (josh:on "2013-07-08")
 "this-is-another-post"
 (blog:markdown
  "#Hello World!

  How are you all today?"
 )
)

; Sort the posts
(sort josh:*posts* josh:date-asc)

(println 
 (josh:render-rss "Hello")
)

(exit)
