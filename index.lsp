(context 'blog)

(define (render-post post)
 (let (_content (get 'content post))
  (expand
   '(div (@class "post")
     (~uq _content)
    )
   '_content)
 )
)

(define (render-index)
 (letn (_title *title* 
        _posts (map render-post *posts*)
        _post-div (extend '(div (@class "posts")) _posts)
        page
         '(html
           (head
            (title _title)
           )
           (body
            _post-div
           )
          )
       )
  (expand page '_title '_post-div)
 )
)

(context 'MAIN)
