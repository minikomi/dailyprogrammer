#lang racket

(define (+%255 a b)
 (modulo (+ a b) 255))

(define (<<16+ a b)
 (+ a (arithmetic-shift b 8)))

(define (chksum s)
 (format "~x"
  (call-with-values
   (lambda ()
    (for/fold ([s1 0][s2 0])
     ([c (string->list s)])
     (define r1 (+%255 s1 (char->integer c)))
     (define r2 (+%255 r1 s2))
     (values r1 r2)))
   <<16+)))

(define test-input 
"3
Fletcher
Sally sells seashells by the seashore.
Les chaussettes de l'archi-duchesse, sont-elles seches ou archi-seches ?")

(define (check-all-lines input)
 (match-let ([(list n lines ...) (string-split input "\n")])
  (for ([line lines]
        [i (range (string->number n))])
   (display (format "~a ~a~n" (add1 i) (chksum line))))))

(module+ test
  (require rackunit)
  (check-equal? (chksum "Fletcher") 
                "d330")
  (check-equal? (chksum "Sally sells seashells by the seashore.")
                "d23e")
  (check-equal? (chksum "Les chaussettes de l'archi-duchesse, sont-elles seches ou archi-seches ?")
                "404d"))
