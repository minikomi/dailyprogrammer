#lang racket

(define challenge1 #<<GRID
xxxx xxxx
   xxx   
x   x   x
xxxxxxxxx
GRID
)

(define challenge2 #<<GRID
xx x xx x  
x  x xx x  
xx   xx  x 
xxxxxxxxx x
         xx
xxxxxxxxxxx
 x x x x x 
  x x x x  
GRID
)


(define (parse-gridstring gs)
  (map string->list (string-split gs "\n")))

(define (chain-expand x y g chn-n chs)
  (if
   (or
    (hash-ref chs (list x y) #f)
    (<= (length g) y)
    (<= (length (first g)) x)
    (> 0 x)
    (> 0 y)) chs
    (if (char=? #\space (list-ref (list-ref g y) x)) chs
        (for/fold
            ([new-chs (hash-set chs (list x y) chn-n)])
            ([xy-mod '([1 0] [0 1] [-1 0] [0 -1])])
          (chain-expand
           (+ (first xy-mod) x)
           (+ (second xy-mod) y)
           g
           chn-n
           new-chs)))))

(define (solve g)
  (define-values [_ c]

    (for/fold
       ([chains (hash)]
        [chain-count 0])
       ([y (in-range (length g))])
     (for/fold
         ([chs chains]
          [cc chain-count])
         ([x (in-range (length (first g)))])
       (cond
         [(hash-ref chs (list x y) #f) (values chs cc)]
         [(char=? #\space (list-ref (list-ref g y) x)) (values chs cc)]
         [else
          (let ([new-count (add1 cc)])
            (values
             (chain-expand x y g new-count chs)
             new-count))]))))
  (displayln
   (~a  "Chains found: " c)))

