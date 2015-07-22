#lang racket/base

#|

Description

We've had our fair share of sorting algorithms, now let's do a shuffling
challenge. In this challenge, your challenge is to take a list of inputs and
change around the order in random ways. Think about shuffling cards - can your
program shuffle cards?

Input Description

You'll be given a list of values - integers, letters, words - in one order. The
input list will be space separated. Example:

1 2 3 4 5 6 7 8

Output Description

Your program should emit the values in any non-sorted order; sequential runs of
the program or function should yield different outputs. You should maximizA e
the disorder if you can. From our example:

7 5 4 3 1 8 2 6

Challenge Input

apple blackberry cherry dragonfruit grapefruit kumquat mango nectarine
persimmon raspberry raspberry

a e i o u

Challenge Output

Examples only, this is all about shuffling

raspberry blackberry nectarine kumquat grapefruit cherry raspberry apple mango
persimmon dragonfruit

e a i o u

Bonus

Check out the Faro shuffle and the Fisher-Yates shuffles, which are algorithms
for specific shuffles. Shuffling has some interesting mathematical properties.

|#


(require net/http-client
         racket/port
         racket/string
         racket/vector
         )

(define target-host "www.random.org")
(define target-url "/sequences/?min=0&max=~a&col=1&format=plain&rnd=new")

(define (true-random-shuffle l) 
  (define-values (c h reply-body)
    (http-sendrecv
     target-host
     (format target-url (sub1 (length l)))
     #:ssl? #t))
  (define new-order (map string->number (string-split (port->string reply-body) "\n")))
  (map (lambda (n) (list-ref l n)) new-order))
