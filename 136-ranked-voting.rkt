#lang racket

; http://www.reddit.com/r/dailyprogrammer/comments/1r2mcz/112013_challenge_136_intermediate_ranked_voting/

; Sample Inputs
; 5 3
; Knuth Turing Church
; 1 0 2
; 0 1 2
; 2 1 0
; 2 1 0
; 1 2 0

(define in
 (string-split
"5 3
Knuth Turing Church
1 0 2
0 1 2
2 1 0
2 1 0
1 2 0"
#px"\n"))

; Sample Outputs
; Round 1: 40.0% Turing, 40.0% Church, 20.0% Knuth
; Round 2: 60.0% Turing, 40.0% Church
; Turing is the winner

(define total
  (string->number
               (first (string-split (first in)))))

(define rounds
  (string->number
                (second (string-split (first in)))))

(define names
  (apply vector (string-split (second in))))

(define rows
  (map (λ (r) (map string->number (string-split r)))
       (drop in 2)))

(define (tally (exclude '()))
  (for/fold
    ([acc (make-hash)])
    ([r rows])
    (let ([vote (findf (λ (x) (not (memv x exclude))) r)])
    (hash-update! acc vote add1 0) acc)))

(define (display-result result)
  (display
   (string-join
    (for/list ([r result])
      (format "~a% ~a"
              (real->decimal-string (* 100 (/ (cdr r) total)) 2)
              (vector-ref names (car r))))
    ", ")))

(define (sort-pair hash)
  (sort (hash->list hash)
        (λ (a b) (> (cdr a) (cdr b)))))

(define (run-vote (round 1) (exclude '()))
  (define result (sort-pair (tally exclude)))
  (display (format "Round ~a: " round))
  (display-result result)
  (newline)
  (cond
    ; Too many rounds
    [(= round rounds) (display "No Winner.")]
    ; Winner!
    [(< (/ total 2) (cdr (first result)))
     (display (format "~a is the winner!~n" (vector-ref names (car (first result)))))]
    ; 50 / 50
    [(apply = (map cdr result)) (display "Draw.")]
    ; Recur.
    [else (begin
            (define lowest (cdr (last result)))
            (define losers (map car (dropf result (λ (r) (< lowest (cdr r))))))
            (run-vote (add1 round) (append exclude losers)))]))

(run-vote)
