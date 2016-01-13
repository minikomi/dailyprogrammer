#lang racket

;; Naive Solution

(define (solve-249 vals (max-pair '(0 0)))
  (if (>= 2 (length vals)) max-pair
      (let* ([current (first vals)]
             [vs      (drop vals 2)]
             [new-max-pair
              (for/fold ([current-max-pair max-pair])
                        ([v vs])
                (if (> (- v current)
                       (- (second current-max-pair)
                          (first current-max-pair)))
                    (list current v)
                    current-max-pair))])
        (solve-249 (rest vals) new-max-pair))))

;; Linear time Solution

(define (solve-249-linear initial-vals)
  (define (solve-loop max-profit low high vals)
    (if (>= 2 (length vals)) (list low (apply max (cons high vals)))
        (if (> low (first vals))
            (solve-loop max-profit (first vals) high (drop vals 2))
            (if (< max-profit (- (first vals) low))
                (solve-loop (- (first vals) low) low (first vals) (rest vals))
                (solve-loop max-profit low high (rest vals))))))
  (solve-loop -inf.f +inf.f -inf.f initial-vals))