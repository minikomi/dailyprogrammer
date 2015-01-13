 #lang racket

 (define (count-letters str)
   (define alphabetic-lowcased
     (map char-downcase 
          (filter char-alphabetic? 
                  (string->list str))))
   (for/fold ([acc (hasheq)])
             ([l alphabetic-lowcased])
     (hash-update acc l add1 0))) 

 (module+ test
   (require rackunit)
   (check-equal? (hasheq #\d 1 #\e 1 #\h 1 #\l 3 #\o 2 #\r 1 #\w 1)
                 (count-letters "Hello World")))