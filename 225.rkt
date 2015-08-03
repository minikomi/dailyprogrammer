#lang racket

(define grid1
#<<GRID
+---+---+---+---+---+---+
                        |
                        |
                        |
+---+---+---+---+---+   +
                        |
                        |
                        |
+---+---+---+---+---+---+
|                        
|                        
|                        
+   +---+---+---+---+---+
|                        
|                        
|                        
+---+---+---+---+---+---+
GRID
)
(define grid2
#<<GRID
+-+-+-+-+-+
  |       |
+ +-+-+ + +
| |     | |
+ + + + + +
|   | |   |
+-+-+ +-+-+
|     |   |
+ + +-+ + +
| |     |  
+-+-+-+-+-+
GRID
)

(define (transpose lists) (apply map list lists))

(define (gridstr->grid gridstr)
  (map string->list (string-split gridstr "\n")))


(define (solve grid)
  (define rows (gridstr->grid grid))
  (define h (length rows))
  (define w (length (first rows)))

  
  (define diag-hash
    (for/fold ([final-grid (hash)])
              ([y (range h)])
      (for/fold ([fg final-grid])
                ([x (range w)])
        (define new-x (+ (- h y 1) x))
        (define new-y (+ x y))
        (hash-set fg (list new-x new-y)
                  (list-ref (list-ref rows y) x)
                  ))))


  
  (define diag
    (for/list ([y (range (+ h w))])
      (for/list ([x (range (+ h w))])
        (case (hash-ref diag-hash (list x y) #\space)
          [(#\-) #\\]
          [(#\|) #\/]
          [(#\+) #\+]
          [else #\space]
          ))))
  
  (define diag-deplussed
    (transpose
     (filter
      (λ (l) (not (member #\+ l)))
      (transpose diag))))

  (define diag-no-empty
    (filter
     (λ (l) (or (member #\\ l) (member #\/ l)))
     diag-deplussed))

  (string-join (map list->string diag-no-empty) "\n")
  ) 
