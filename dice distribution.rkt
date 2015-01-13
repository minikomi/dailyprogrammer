#lang racket

(require plot)

(define (generate-distribution n)
  (for/fold ([acc (hash)])
            ([i (range n)]) 
    (hash-update acc 
                 (add1 (random 6)) 
                 (λ (x) (add1 x)) 0)))


(define (plot-distribution n)
  (define dist-hash (generate-distribution n))
  (define dist-vals (hash-map dist-hash (λ (k v) 
                                          (vector k (* 100 (/ v n))))))
  (plot (discrete-histogram dist-vals)
        #:x-label "Number Rolled" 
        #:y-label "% of rolls"))