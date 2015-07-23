#lang racket/base 

(require racket/list)

(define data
  '((a b 7)
    (a c 9)
    (a f 14)
    (b c 10)
    (b d 15)
    (c d 11)
    (c f 2)
    (d e 6)
    (e f 9)))

(define data2 
  '((4 5 0.35)
    (5 4 0.35)
    (4 7 0.37)
    (5 7 0.28)
    (7 5 0.28)
    (5 1 0.32)
    (0 4 0.38)
    (0 2 0.26)
    (7 3 0.39)
    (1 3 0.29)
    (2 7 0.34)
    (6 2 0.40)
    (3 6 0.52)
    (6 0 0.58)
    (6 4 0.93)))

(define data3
  '((1 3 21)
    (3 2 21)
    (1 4 1)
    (4 5 1)
    (5 2 1)
    ))

(define-struct node (cost path) #:transparent)

(define (build-graph-directed edges)
  (for/fold ([graph (hash)])
            ([edge edges])
            (define-values (n1 n2 v)
              (values (first edge) (second edge) (third edge)))
            (hash-update graph n1
                         (lambda (adj-list) (cons (list n2 v) adj-list))
                         (list)) 
            ))

(define (build-graph-undirected edges)
  (for/fold ([graph (hash)])
            ([edge edges])
            (define-values (n1 n2 v)
              (values (first edge) (second edge) (third edge)))
            (hash-update
              (hash-update graph n1 (lambda (adj-list) (cons (list n2 v) adj-list)) (list))
              n2 (lambda (adj-list) (cons (list n1 v) adj-list)) (list)) 
            ))

(define (build-costs-hash graph start) 
  (make-immutable-hash 
    (map (lambda (n) (cons n (make-node (if (equal? start n) 0 +inf.0) '())))
         (hash-keys graph))))

(define (dijkstra graph start finish)
  ; all nodes are unvisited and have undefined cost
  ; origin which has cost 0
  (define initial-costs (build-costs-hash graph start))

  (define (dijkstra-solve current remaining costs-table)
    (if (equal? current finish) 
      ; if we made it to the end, return the costs table.
      costs-table 
      ; set up current node value, cost, neighbours
      (let* ([current-node      (hash-ref costs-table current)]
             [current-node-cost (node-cost current-node)]
             [neighbours        (hash-ref remaining current)])

        ; modify the costs table in a fold, return new table and current lowest neighbour
        (define-values [costs-table-new current-new _]
          (for/fold ([costs costs-table]
                     [min-neighbour #f]
                     [min-val +inf.0])
                    ([n neighbours]
                     #:when (hash-has-key? remaining (first n)))

                    (define-values [neighbour-name edge-cost] (values (first n) (second n))) 

                    ; for this neighbour calculate the cost
                    (define new-cost-for-neighbour (+ current-node-cost edge-cost))
                    (define prev-cost-for-neighbour (node-cost (hash-ref costs neighbour-name)))

                    ; if the cost is the minimum, update our current min.
                    ; othterwise, keep it the same
                    (define-values [min-neighbour-new min-val-new]
                      (if (< new-cost-for-neighbour min-val)
                        (values (first n) new-cost-for-neighbour)
                        (values min-neighbour min-val)))

                    ; if, in our costs table, the new path generates the lowest cost,
                    ; update the costs table for that node
                    (define costs-new
                      (if (< new-cost-for-neighbour prev-cost-for-neighbour)
                        (hash-update costs 
                                     neighbour-name
                                     (lambda (nd) 
                                       (struct-copy node nd 
                                                    (cost new-cost-for-neighbour)
                                                    (path (cons current (node-path current-node))))))
                        costs))

                    (values costs-new min-neighbour-new min-val-new)))

        (dijkstra-solve current-new 
                        (hash-remove remaining current) 
                        costs-table-new)
        )))

  (dijkstra-solve start graph initial-costs)) 
