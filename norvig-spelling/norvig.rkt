#lang racket

(require racket/port)

(define (words text)
  (string-split (string-downcase text) #rx"[^a-z]+"))

(define (train features)
  (for/fold ([model (hash)])
            ([f features])
    (hash-update model f add1 1)))

(define NWORDS
  (call-with-input-file "big.txt"
    (λ (txt) (train (words (port->string txt))))))

(define alphabet "abcdefghijklmnopqrstuvwxyz")

(define (edits1 word)
  (define splits
    (for/list ([i (range (add1 (string-length word)))])
      (list (substring word 0 i)
            (substring word i))))
  
  (define deletes
    (for/set ([s splits]
              #:when (not (equal? "" (second s))))
      (match-define (list a b) s)
      (string-append a (substring b 1))))

  (define transposes
    (for/set ([s splits]
              #:when (< 1 (string-length (second s))))
      (match-define (list a b) s)
      (string-append a
                     (substring b 1 2)
                     (substring b 0 1)
                     (substring b 2)
                     )))

  (define replaces
    (for*/set ([s splits]
               #:when (not (equal? "" (second s)))
               [c alphabet])
      (match-define (list a b) s)
      (string-append a
                     (string c)
                     (substring b 1)
                     )))

  (define inserts
    (for*/set ([s splits]
               [c alphabet])
      (match-define (list a b) s)
      (string-append a
                     (string c)
                     b 
                     )))

  (set-union deletes transposes inserts replaces)) 

(define (known-edits2 word)
  (for*/fold
      ([edit-set (set)])
      ([e1 (edits1 word)]
       [e2 (edits1 e1)]
       #:when (hash-ref NWORDS e2 #f))
    (set-add edit-set e2)))

(define (known word-candidates)
  (define known-words-from-candidates
    (filter (λ (w) (hash-ref NWORDS w #f))
            word-candidates))
  (if (empty? known-words-from-candidates)
      #f
      (apply set known-words-from-candidates)))

(define (correct word)
  (define candidates
    (or
     (known (list word))
     (known (set->list (edits1 word)))
     (known-edits2 word)
     word))
  (sort (set->list candidates)
        (λ (c1 c2)
          (> (hash-ref NWORDS c1) (hash-ref NWORDS c2)))))



