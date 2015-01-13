 #lang racket/base

 (require net/http-client
          racket/port
          racket/string
          racket/vector
          )

 (define target-host "www.random.org")
 (define target-url "/sequences/?min=0&max=~a&col=1&format=plain&rnd=new")

 (define (true-random-shuffle s) 
   (define-values (c h reply-body)
     (http-sendrecv
       target-host
       (format target-url (sub1 (string-length s)))))

   (define new-order (map string->number  (string-split (port->string reply-body) "\n")))
   (list->string (map (lambda (n) (string-ref s n)) new-order)))

 (define (bogo input target [n 0])
   (if (string=? input target)
     (displayln (format "Success after ~a time~a: ~a - ~a" n (if (= n 1) "" "s") input target))
     (begin
       (displayln (format "Bogoed ~a time~a. Current Result: ~a != ~a." n (if (= n 1) "" "s") input target))
       (displayln "bogo shuffling after 1s Sleep...")
       (sleep 1)
       (let ([bogo-shuffled (true-random-shuffle input)])
         (bogo bogo-shuffled target (add1 n))))))

 (define args (current-command-line-arguments))

 (if (= (vector-length args) 2)
   (bogo (vector-ref args 0)(vector-ref args 1))
   (displayln "Usage: boko.rkt input target"))