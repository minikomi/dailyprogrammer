#lang racket

(define (word-mangle word)
  (define-values (letters punctuation-positions cap-positions word-len)
    (for/fold
        [(letters '())
         (punc-pos (hash))
         (cap-pos (hash))
         (idx 0)]
        [(ch word)]
      (if (char-alphabetic? ch)
          ; char is alphabetic
          (values
           (cons (char-downcase ch) letters)
           punc-pos
           (if (char-upper-case? ch)
               (hash-set cap-pos idx ch)
               cap-pos)
           (add1 idx))
          ; char is punctuation
          (values
           letters 
           (hash-set punc-pos idx ch)
           cap-pos
           (add1 idx))
          )))
  
  (define sorted-letters (sort letters char<=?))

  (define (build-word remaining-letters idx built)
    (if (= word-len idx) built
        (let ([maybe-punctuation (hash-ref punctuation-positions idx #f)])
          (if maybe-punctuation
              (build-word
               remaining-letters
               (add1 idx)
               (cons maybe-punctuation built))
              (build-word
               (rest remaining-letters)
               (add1 idx)
               (cons (if (hash-ref cap-positions idx #f)
                         (char-upcase (first remaining-letters))
                         (first remaining-letters))
                     built)
               )))))
  (list->string (reverse (build-word sorted-letters 0 '()))))

(define (mangle str)
  (define words (string-split str))
  (string-join (map word-mangle words) " "))

(module+ test
  (require rackunit)
  (check-equal?
   "Hist aceeghlln denos't eems os adhr."
   (mangle "This challenge doesn't seem so hard."))
  (check-equal?
   "Eehrt aer emor ghinst beeentw aeehnv adn aehrt, Ahioort, ahnt aer ademrt fo in oruy hhilooppsy."
   (mangle "There are more things between heaven and earth, Horatio, than are dreamt of in your philosophy.")))