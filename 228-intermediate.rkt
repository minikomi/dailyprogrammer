#! /usr/local/bin/racket
#lang racket/base

(require net/http-client
         racket/list
         racket/string
         racket/format
         racket/cmdline)

(define valid-markets
  (list "bitfinex" "bitstamp" "btce" "itbit" "anxhk"
        "hitbtc" "kraken" "bitkonan" "bitbay" "rock"
        "cbx" "cotr" "vcx"))

(define valid-currencies
  (list  "KRW" "NMC" "IDR" "RON" "ARS" "AUD"
         "BGN" "BRL" "BTC" "CAD" "CHF" "CLP"
         "CNY" "CZK" "DKK" "EUR" "GAU" "GBP"
         "HKD" "HUF" "ILS" "INR" "JPY" "LTC"
         "MXN" "NOK" "NZD" "PEN" "PLN" "RUB"
         "SAR" "SEK" "SGD" "SLL" "THB" "UAH"
         "USD" "XRP" "ZAR"))

(define (confirm-inputs market currency)
  (cond
    [(not (member market valid-markets))
     (begin
       (displayln "Not a valid market. Please choose one of:")
       (for ([vm valid-markets])
         (displayln vm))
       #f)]
    [(not (member currency valid-currencies))
     (begin
       (displayln "Not a valid currency. Please choose one of:")
       (for ([vc valid-currencies])
         (displayln vc))
       #f)]
    [else #t]))


(define api-host "api.bitcoincharts.com")

(define api-uri "/v1/trades.csv")

(define (gen-full-uri market currency)
  (string-append api-uri "?symbol=" market currency))

(define (get-current-bitcoin-price market currency)
  (when (confirm-inputs market currency)
    (let-values 
        ([(status headers res)
          (http-sendrecv api-host (gen-full-uri market currency))])
      (if (equal? #"HTTP/1.1 200 OK" status)
          (let* ([first-row (read-line res)]
                 [t-p-a (string-split first-row ",")])
            (if (= (length t-p-a) 3)
                (displayln
                 (~a "BTC/" currency " on "
                     market " at " (first t-p-a) ": "
                     (~r (string->number (second t-p-a)) #:precision 2)))
                (displayln (~a "Sorry, could not parse CSV data:\n" first-row))))
          (displayln
           (~a "Sorry, the request failed (" status ")"))))))

(module+ main
  (define market-currency-cmdline
    (command-line
     #:program "Bitcoin Price"
     #:final
     [("--list-markets" "-m") "List available markets." (begin (displayln (string-join valid-markets " ")) (exit)) ]
     [("--list-currencies" "-c") "List available currencies." (begin (displayln (string-join valid-currencies " ")) (exit))]
     #:args (market currency)
     (get-current-bitcoin-price market currency))))


