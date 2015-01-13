#lang racket/base
(require (planet neil/charterm))

(with-charterm
  (define char-chan (make-channel))

  (thread
    (lambda ()
      (define (inner-loop)
        (channel-put char-chan (charterm-read-key))
        (inner-loop))
      (inner-loop)))

  (define (loop ch) 
    (if (char=? #\q ch) (close-charterm)
      (begin
        (charterm-clear-screen)
        (charterm-cursor (random 30) (random 6))
        (charterm-normal)
        (charterm-display ch)
        (charterm-cursor 1 1)
        (charterm-display "Press a key...")
        (let ((newch (channel-try-get char-chan)))
          (sleep 0.2)
          (loop  (if newch newch ch))))))
  (loop #\x))

