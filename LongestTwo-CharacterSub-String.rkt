#lang racket

; http://www.reddit.com/r/dailyprogrammer/comments/1g0tw1/easy_longest_twocharacter_substring/

(define (longer a b)
 (if (>= (length a) (length b)) a b))

(define (longest-2char l)
 (cond [(>= 2 (set-count (apply set l))) l]
  [(>= 2 (length l)) l]
  [else
  (longer (longest-2char (rest l))
   (longest-2char (drop-right l 1)))]))

(define (longest-2char-str s)
 (list->string
  (longest-2char
   (string->list s))))

  (module+ test
   (require rackunit)
   (check-equal? 
    "bbccc"
    (longest-2char-str "abbccc"))
   (check-equal?
    "bccc"
    (longest-2char-str "abcabcabcabccc"))
   (check-equal?
    "yyyyyyyyyyq"
    (longest-2char-str "tyyyyyyyyyyqwertyyyy")))
