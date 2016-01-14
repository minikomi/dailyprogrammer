#lang racket

(define-struct candidate (fitness val) #:transparent)

(define (hamming-distance s1 s2)
  (for/fold ([h 0]) ([c1 s1][c2 s2])
    (if (char=? c1 c2) h (add1 h))))

(define (fitness t s) (- (string-length t) (hamming-distance t s)))

(define (random-char) (integer->char (+ 32 (random 94))))
   
(define (generate-population target pop-size)
  (build-list pop-size
   (λ (_)
     (let ([v (list->string
               (build-list (string-length target)
                           (λ (_) (random-char))))])
       (make-candidate (fitness target v) v)))))

(define (sort-by-fitness target pop)
  (sort pop
        (λ (a b) (> (candidate-fitness a)
                    (candidate-fitness b)))))

(define (sort-and-cull target pop rate)
  (drop-right (sort-by-fitness target pop)
              (inexact->exact (floor (* (length pop) rate)))))

(define (weighted-random culled)
  (define total-weight
    (apply + (map (λ (c) (add1 (candidate-fitness c) )) culled)))
  (define random-weight (random total-weight))
  (define (select-loop c w)
    (if (or (>= (candidate-fitness (first c)) w)
            (= 1 (length c)))
        (first c)
        (select-loop (rest c) (- w 1 (candidate-fitness (first c))))))
  (select-loop culled random-weight))
    
(define (weighted-breed target culled)
  (define p1 (weighted-random culled))
  (define p2 (weighted-random (remove p1 culled)))
  (define new-v
    (list->string
     (build-list
      (string-length target)
      (λ (n) (cond
               [(char=?
                 (string-ref (candidate-val p1) n)
                 (string-ref target n))
                (string-ref target n)]
               [(char=?
                 (string-ref (candidate-val p2) n)
                 (string-ref target n))
                (string-ref target n)]
               [else
                (if (< 0.5 (random))
                    (random-char)
                    (string-ref
                     (if (< 0.5 (random))
                         (candidate-val p1)
                         (candidate-val p2))
                     n))])))))
  (make-candidate (fitness target new-v) new-v))

(define (next-generation target cull-rate pop)
  (define pop-size (length pop))
  (define culled (sort-and-cull target pop cull-rate))
  (sort-by-fitness target
   (append culled
          (build-list (inexact->exact (* pop-size cull-rate))
                      (λ (_) (weighted-breed target culled))))))

(define (249-intermediate target pop-size cull-rate max-iter)
  (define initial-pop (generate-population target pop-size))
  (define (iter pop n)
    (cond [(= (string-length target) (candidate-fitness (first pop)))
           (first pop)]
          [(< max-iter n) (displayln "fail") (first pop)]
          [else
           (begin
               (displayln (format "Gen: ~a | Fitness ~a | ~a"
                                  n
                                  (candidate-fitness (first pop))
                                  (candidate-val (first pop))))           
             (iter (next-generation target cull-rate pop) (add1 n)))]))
  (iter initial-pop 0))
           




  


  
    
               