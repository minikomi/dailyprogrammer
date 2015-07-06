#lang racket

(define test-snake #<<SNAKE
SHENANIGANS       DOUBLET
          A       N     E
          L       U     R
          T       O     A
          YOUNGSTER     B
                        Y
                        T
                  ECNESSE
SNAKE
)

(define test-snake2 #<<SNAKE
R       TIGER
E       O   E
S       H   T  SO
I  GRAPES   U  N
G  A        R  R
NULL  GNIHTON  E
      R        T
      A        N
      N        A
      DELIGHTFUL
SNAKE
)


(define-struct matrix (w h grid) #:transparent)

(define (str->mtx str)
  (let ([grid (map string->list
                   (string-split str "\n"))])
    (matrix
     (length grid)
     (length (first grid))
     grid)))

(define (mtx-lookup mtx x y)
  (match-define (matrix w h g) mtx)
  (cond
    [(or (> 0 x)
         (> 0 y))
     'outside]
    [(or (<= w y)
         (<= h x))
     'outside]
    [else
     (list-ref (list-ref g y) x)]
    ))

(define offsets
  (hash
   'W '[-1 0]
   'E '[1 0]
   'N '[0 -1]
   'S '[0 1]))

(define (opposite? dir1 dir2)
  (case (list dir1 dir2)
    ['(N S) #t]
    ['(E W) #t]
    ['(S N) #t]
    ['(W E) #t]
    [else #f]))

(define (change-direction current mtx x y)
  (findf
   (λ (direction)
     (and
      (not (equal? direction current))
      (not (opposite? direction current))
      (let* ([offset-pair (hash-ref offsets direction)]
             [v (mtx-lookup mtx
                            (+ x (first offset-pair))
                            (+ y (second offset-pair)))])
        (and (not (equal? 'outside v))
             (not (equal? #\space v))))))
   '(N S E W)))

(define (unravel snake-string)
  
  (define snake-matrix (str->mtx snake-string))

  (define (unravel-loop dir x y current-word words)
    (match-define (list x-offset y-offset) (hash-ref offsets dir))
    (define-values (new-x new-y) (values (+ x x-offset) (+ y y-offset)))
    (define next-char (mtx-lookup snake-matrix new-x new-y))
    (if (or (equal? #\space next-char) 
            (equal? 'outside next-char))
        (let ([new-direction (change-direction dir snake-matrix x y)]         ; edge or end of word
              [new-words (cons (list->string (reverse current-word)) words)]
              [new-word (list (mtx-lookup snake-matrix x y))])
          (if (not new-direction)
              (reverse (cons (list->string (reverse current-word)) words))    ; nowhere to go - return result
              (unravel-loop new-direction x y new-word new-words)))           ; start new word
        (unravel-loop dir new-x new-y (cons next-char current-word) words)    ; continue current word
        ))
  
  (define first-direction (change-direction #f snake-matrix 0 0))             ; | 
  (define start-word (list (mtx-lookup snake-matrix 0 0)))                    ; |
  
  (unravel-loop first-direction 0 0 start-word '())               ; kickoff loop
  )
