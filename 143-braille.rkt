#lang racket

(define (decode braile-string)
  (define split-b (map (λ (x) (string-split x #px" ")) (string-split braile-string "\n")))
  (define char-b 
    (for/list ([l1 (first split-b)]
               [l2 (second split-b)]
               [l3 (third split-b)])
      (list l1 l2 l3)))
  (list->string 
   (map (λ (x) 
          (hash-ref 
           (for/hash ([d '(32 40 48 52 36 56 60 44 24 28 34 42 50 54 38 58 62 46 26 30 35 43 29 55 39)]
                      [c (map integer->char (stream->list (in-range 97 122)))])
             (values d c))
           (string->number 
            (string-replace 
             (string-replace 
              (apply string-append x) "." "0") "O" "1") 2))) char-b)))

(module+ test
  (require rackunit)

  (define in 
"O. O. O. O. O. .O O. O. O. OO
OO .O O. O. .O OO .O OO O. .O
.. .. O. O. O. .O O. O. O. ..")
  (check-equal? (decode in) "helloworld"))
