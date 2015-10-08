#lang racket

(define test-input-1 "X X X X X X X X X XXX")
(define test-input-2 "X -/ X 5- 8/ 9- X 81 1- 4/X")
(define test-input-3 "62 71  X 9- 8/  X  X 35 72 5/8")

(define (parse-input input)
  (map string->list
       (string-split input)))

(define (frame->score frame)
  (displayln (~a "frame: " frame))
  (define (loop remain tally)
    (if (empty? remain) tally
        (cond
          [(char=? (first remain) #\-)
           (loop (rest remain) tally)]
          [(char=? (first remain) #\X)
           (loop (rest remain) (+ tally 10))]
          [(char=? (first remain) #\/)
           (loop (rest remain) 10)]
          [else
           (loop (rest remain)
                 (+ tally
                    (- (char->integer (first remain)) 48)))]
          )))
  (loop frame 0))

(module+ test
  (require rackunit)
  ;; strike
  (check-eq? 10
             (frame->score (list #\X)))
  (check-eq? 30
             (frame->score (list #\X #\X #\X)))
  ;; gutter
  (check-eq? 4
             (frame->score (list #\- #\4)))
  ;; spare
  (check-eq? 10
             (frame->score (list #\4 #\/)))
  (check-eq? 15
             (frame->score (list #\- #\/ #\4)))
  )

(define (add-bonus-frames frames tally frame-type)
  (case frame-type
    ['strike (+ tally 10 (frame->score (take (flatten (rest frames)) 2)))]
    ['spare (+ tally 10 (frame->score (take (flatten (rest frames)) 1)))]
    ))

(define (tally-game frames (tally 0))
  (displayln tally)
  (if (= (length frames) 1)
      (+ tally
         (frame->score (first frames)))
      (tally-game (rest frames)
                  (cond
                    [(member #\X (first frames))
                     (add-bonus-frames frames tally 'strike)]
                    [(member #\/ (first frames))
                     (add-bonus-frames frames tally 'spare)]
                    [else
                     (+ tally (frame->score (first frames)))])))) 
