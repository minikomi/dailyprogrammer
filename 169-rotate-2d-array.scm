(define (matrix-rotate M)
  (if (null? (car M))
      '()
      (cons (reverse (map car M))
            (matrix-rotate (map cdr M)))))

(define (print-matrix M)
  (for-each (lambda (row) (display row) (newline)) M))

(define test-input
  (list
    (list 1 2 3 4 5 6 7 8 9 0)
    (list 0 9 8 7 6 5 4 3 2 1)
    (list 1 3 5 7 9 2 4 6 8 0)
    (list 0 8 6 4 2 9 7 5 3 1)
    (list 0 1 2 3 4 5 4 3 2 1)
    (list 9 8 7 6 5 6 7 8 9 0)
    (list 1 1 1 1 1 1 1 1 1 1)
    (list 2 2 2 2 2 2 2 2 2 2)
    (list 9 8 7 6 7 8 9 8 7 6)
    (list 0 0 0 0 0 0 0 0 0 0)))

(define (main args)
  (print-matrix (matrix-rotate test-input)))