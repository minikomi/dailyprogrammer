#lang racket

(define (splice lst idx new)
  (append (take lst idx) 
          (cons new (drop lst (add1 idx)))))

(define combinations
  '(; rows
    (0 1 2)(3 4 5)(6 7 8)
    ; cols
    (0 3 6)(1 4 7)(2 5 8)
    ; diags
    (0 4 8)(2 4 6)))

(define (generate-combinations board)
  (for/list ([c combinations])
    (map (λ (i) (list-ref board i)) c)))

(define (winner? player combination)
  (= 3 (count (curry char=? player) combination)))

(define (blocker? player combination)
  (and
   (= 1 (count (curry char=? player) combination))
   (= 0 (count (curry char=? #\-) combination))))

(define (generate-results board player)
  (for/fold ([acc (hash 'wins '() 'blocks '())]) 
            ([i (in-range 9)]
            #:when (char=? #\- (list-ref board i)))
    (define updated-board-combinations (generate-combinations 
                                        (splice board i player)))
    (cond
      [(findf (curry winner? player) updated-board-combinations)
       (hash-update acc 'wins (λ (wins) (cons i wins)))]
      [(findf (curry blocker? player) updated-board-combinations)
       (hash-update acc 'blocks (λ (blocks) (cons i blocks)))]
      [else acc])))

(define (print-board board)
  (displayln (list->string (take board 3)))
  (displayln (list->string (take (drop board 3) 3)))
  (displayln (list->string (drop board 6)))
  (newline))

(define (winning-moves board player)
  (define results (generate-results board player))
  (cond
    [(not (empty? (hash-ref results 'wins)))
     (for ([w-idx (reverse (hash-ref results 'wins))])
       (display (format "Winning move for ~a at index ~a!~n" player w-idx))
       (print-board (splice board w-idx player)))]
    [(not (empty? (hash-ref results 'blocks)))
     (let ([b-idx (first (hash-ref results 'blocks))])
       (display (format "There's nothing for ~a to do but block at ~a.~n" player b-idx))
       (print-board (splice board b-idx player)))]
    [else (display (format "I'm not seeing anything for ~a.~n" player))]))

; ----- test boards -----

(define test-wins-board
  (string->list
   (string-replace
    #<<BOARD
XX-
-XO
OO-
BOARD
    "\n" "")))

(define test-block-board
  (string->list
   (string-replace
    #<<BOARD
O-X
-O-
---
BOARD
    "\n" "")))

(define test-no-win-board
  (string->list
   (string-replace
    #<<BOARD
--O
OXX
---
BOARD
    "\n" "")))

(displayln "----- Winning board for X -----")
(winning-moves test-wins-board #\X)
(newline)
(displayln "----- Block board for X -----")
(winning-moves test-block-board #\X)
(newline)
(displayln "----- No win board for X -----")
(winning-moves test-no-win-board #\X)

