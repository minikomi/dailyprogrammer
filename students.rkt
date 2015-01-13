#lang racket


(define challenge-input 
  #<<INPUT
Jennifer ,  Adams   100 70  85  86  79
Bubba , Bo Bob  50  55  60  53  30
Matt ,  Brown   72  82  92  88  79
Ned ,   Bundy   73  75  80  79  88
Alfred ,    Butler  80  90  70  100 60
Sarah , Cortez  90  72  61  70  80
William ,   Fence   88  86  83  70  79
Casper ,    Ghost   80  85  87  89  90
Opie ,  Griffith    90  90  90  90  90
Tony ,  Hawk    60  60  60  72  72
Kirstin ,   Hill    100 90  92  94  95
Hodor , Hodor   40  50  53  62  33
Clark , Kent    89  90  88  92  91
Tyrion ,    Lannister   93  97  100 91  95
Ken ,   Larson  70  80  85  73  79
Stannis ,   Mannis  60  70  75  77  78
Bob ,   Martinez    79  88  92  82  72
Jean Luc ,  Picard  90  89  95  70  65
Harry , Potter  73  75  77  69  73
Jaina , Proudmoore  90  92  100 95  94
Richie ,    Rich    88  90  87  91  86
John ,  Smith   90  80  70  60  50
Jon ,   Snow    70  70  70  70  72
Arya ,  Stark   91  92  90  93  90
Edwin , Van Clef    40  50  55  57  33
Valerie ,   Vetter  79  81  78  83  80
Katelyn ,   Weekes  90  95  92  93  97
Wil  , Wheaton  70  80  75  71  77
Steve , Wozniak 88  89  87  86  85
Derek , Zoolander   80  81  85  88  90
INPUT
  )



(define (parse-line line)
  (match (string-split line) 
    [(list (and first-name (regexp #px"[[:alpha:]]"))  ... "," 
           (and last-name  (regexp #px"[[:alpha:]]"))  ...
           (and grades     (regexp #px"[[:digit:]]+")) ...)
     (hash 'first-name     (string-join first-name " ")
           'last-name      (string-join last-name  " ")
           'all-grades     (map string->number grades))]))

(define (input->grades input) 
  (map parse-line (string-split challenge-input #px"[\r\n]")))

(define (minus-grade? score)
  (>= 3 (modulo score 10)))

(define (plus-grade? score)
  (<= 8 (modulo score 10)))

(define (classify-grade score)
  ; first get the grade
  (define grade
    (cond [(<= 90 score) "A"]
          [(<= 80 score) "B"]
          [(<= 70 score) "C"]
          [(<= 60 score) "D"]
          [(<= 50 score) "E"]
          [else          "F"]))
  ; then modify if needed.
  (match (list grade score)
    ; F is just an F.
    [(list "F" _) "F "]
    ; A can be A-
    [(list "A" (? minus-grade?)) "A-"]
    [(list "A" _)                "A "]
    ; Otherwise, + or -.
    [(list grade (? minus-grade?)) (string-append grade "-")]
    [(list grade (? plus-grade?))  (string-append grade "+")]
    [(list grade _) (string-append grade " ")]
    ))

(define (add-grade-average student-hash)
  (define final-score (round
                       (/ (apply + (hash-ref student-hash 'all-grades))
                          5)))
  (hash-set* student-hash
             'final-score final-score
             'final-grade (classify-grade final-score)))

(define (assess-students input)
  (define parsed 
    (map add-grade-average (input->grades input)))
  (sort parsed (λ (a b) 
                 (define score-a (hash-ref a 'final-score))
                 (define score-b (hash-ref b 'final-score))
                 (if (= score-a score-b) 
                     (string<?  (hash-ref a 'last-name) (hash-ref b 'last-name))
                     (> score-a score-b)))))

(define (pretty-print student-list)
  (define first-names (map (λ (s) (string-length (hash-ref s 'last-name))) student-list))
  (define last-names  (map (λ (s) (string-length (hash-ref s 'last-name))) student-list))
  (define longest-first-name-length (first (sort first-names >)))
  (define longest-last-name-length  (first (sort last-names >)))
  (define grade-length              (string-length "Grade"))
  (define average-length            (string-length "Avg"))
  (define max-scores-length         (* 5 4))
  (displayln (string-join
              (list 
               (~a "First" #:min-width longest-first-name-length)
               (~a "Last" #:min-width longest-last-name-length)
               "Grade"
               "Avg"
               " | "
               "Scores") " "))
  (displayln 
   (string-append
    (string-join
     (map (λ (n) (make-string n #\-))
          (list longest-first-name-length longest-last-name-length grade-length average-length))
     " ")
    " --- "
    (make-string max-scores-length #\-)))
  (for ([student student-list])
    (displayln
     (string-join
      (list
       (~a (hash-ref student 'first-name) #:min-width longest-first-name-length)
       (~a (hash-ref student 'last-name)   #:min-width longest-last-name-length)
       (~a (hash-ref student 'final-grade) #:min-width grade-length #:align 'right )
       (~a (hash-ref student 'final-score) #:min-width average-length #:align 'right )
       " | "
       (~a (string-join (map (λ (n) (~a n #:min-width 4 #:align 'right " "))
                             (sort (hash-ref student 'all-grades) >)) "")
           #:min-width average-length)) " "))))



