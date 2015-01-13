#lang racket

(define test-input 
"The quick brown fox jumps over the lazy dog.
Or, did it?")

(define test-input-2
"I would not, could not, in the rain.
Not in the dark. Not on a train.
Not in a car. Not in a tree.
I do not like them, Sam, you see.
Not in a house. Not in a box.
Not with a mouse. Not with a fox.
I will not eat them here or there.
I do not like them anywhere!")

(define test-hyphen
"Well, this so-and-so told me to go eat my hat!")

(define test-error
"Well, this so-and-so to!!!!ld me to go eat my hat!")

(define (split-txt txt)
  (string-split 
   (string-replace 
    (string-replace txt #px"[\r\n]" " <R> ") 
    "-" " - ")))

; Takes in a word with possible punc on the end.
; - if there's an allowed punc, return '(word punc)
; - otherwise just '(word)
(define (tokenize input-word)
  (match input-word
    [(regexp #px"\\w*([\\.,?!;:])" (list w p))
     (list (string-downcase 
            (substring w 0 (sub1 (string-length w)))) p)]
    [_ (list (string-downcase input-word))]))

(define (add-token dict compressed word modifier)
  (define tokenized (tokenize word))
  (define current-word (first tokenized))
  (if (hash-has-key? dict current-word)
      ; already in dictionary
      (values dict 
              (append compressed 
                      (cons (~a (hash-ref dict current-word) modifier) 
                            (rest tokenized))))
      ; new word
      (let ([new-word-value (hash-count dict)])
        (values (hash-set dict current-word new-word-value)
                (append compressed 
                        (cons (~a new-word-value modifier) 
                              (rest tokenized)))))))

(define (create-dictionary-and-compressed-phrase input)
    (for/fold ([dict (hash)]
             [compressed '()])
    ([word (split-txt input)])
    (match word
      ["-" (values dict (append compressed (list word)))]
      ["<R>" (values dict (append compressed (list "R")))]
      [(pregexp #px"^[[:upper:]][[:lower:]]+[\\.,?!;:]{,1}$")
       (add-token dict compressed word "^")]
      [(pregexp #px"^[[:upper:]]+[\\.,?!;:]{,1}$")
       (add-token dict compressed word "!")]
      [(pregexp #px"^[[:lower:]]+[\\.,?!;:]{,1}$")
       (add-token dict compressed word "")]
      [_ (raise "Parse Error")])))

(define (challenge-162 input)
  (define-values (dict compressed)
    (create-dictionary-and-compressed-phrase input))
  
  ; Number of keys
  (displayln (hash-count dict))
  
  ; Keys in order
  (define sorted-dict-keys
    (map car 
         (sort (hash->list dict)
          (λ (a b) (< (cdr a) (cdr b))))))
  
  (displayln (string-join sorted-dict-keys "\n"))
  
  ; compressed phrase
  (displayln (string-append (string-join compressed) " E")))