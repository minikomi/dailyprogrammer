#lang racket

(require json
         net/http-client
         web-server/http
         web-server/servlet
         web-server/servlet-env
         web-server/formlets
         web-server/dispatch
         )

(define gist-token "0e745fe6900a8d106d120cab954a8ff4ae19d229")
(define diary-gist-id "f0c2f568913665259620")
(define gist-url (string-append "/gists/" diary-gist-id "?access_token=" gist-token))
(define diary-file-name 'geodiary.geojson)

(define (create-point lat long note)
  (hasheq 'type "Feature"
          'properties (hasheq 'note note
                              'timestamp (current-inexact-milliseconds))
          'geometry (hasheq 'type "Point"
                            'coordinates (list long lat))))


(define (get-current-diary)
  (define-values (h t response-body)
    (http-sendrecv
      "api.github.com"
      gist-url
      #:ssl? #t
      ))
  (define response-json (string->jsexpr (port->string response-body)))
  (define current-content (hash-ref (hash-ref (hash-ref response-json 'files) diary-file-name) 'content))
  (string->jsexpr current-content))

(define (send-updated-features geojsxpr)
  (define update-patch
    (jsexpr->string (hasheq 'description ""
                            'files (hasheq diary-file-name
                                           (hasheq 'content (jsexpr->string geojsxpr))))))
  (http-sendrecv "api.github.com"
                  gist-url
                  #:ssl? #t
                  #:method "PATCH"
                  #:data update-patch))

(define (add-point current lat long (note ""))
  (define new-geojsxpr (hash-update current 'features
               (λ (fs) (cons (create-point lat long note)
                             fs))))
  (send-updated-features new-geojsxpr))


(define diary-formlet
  (formlet
   (#%# ,{(required (hidden "0")) . => . lat}
        ,{(required (hidden "0")) . => . long}
        ,{input-string . => . note})
   (values lat long note)))

(define js-str 
#<<JS
var lat = document.getElementsByName("input_0")[0];
var long = document.getElementsByName("input_1")[0];

var lat_h2 = document.getElementById("lat");
var long_h2 = document.getElementById("long");

function resetLatLong(){
    navigator.geolocation.getCurrentPosition(function(d){
        lat.value = d.coords.latitude;
        lat_h2.innerHTML = "lat:" + d.coords.latitude;
        long.value = d.coords.longitude;
        long_h2.innerHTML = "long:" + d.coords.longitude;

        setTimeout(resetLatLong, 2000);
    });
}
resetLatLong();
JS
)

(define (index-handler req)
  (response/xexpr
    `(html (head (title "geodiary")
                 (meta ((name "viewport") (content "width=device-width, user-scalable=no")))
                 )
           (body
             (h1 "geodiary")
             (h2 ((id "long")) "")
             (h2 ((id "lat")) "")
             (form ([action "/"] [method "POST"])
                   ,@(formlet-display diary-formlet)
                   (input ([type "submit"])))
             (script ((src "https://gist.github.com/minikomi/f0c2f568913665259620.js")))
             (script ,js-str)))))

(define (update-handler req)
   (define-values (lat long note)
              (formlet-process diary-formlet req))
  (add-point (get-current-diary) 
             (string->number (bytes->string/utf-8 lat))
             (string->number (bytes->string/utf-8 long))
             note)
  (redirect-to "/" permanently))

(define-values [main-dispatch url-gen]
  (dispatch-rules
    [("") #:method "get"  index-handler]
    [("") #:method "post" update-handler]
    ))

(serve/servlet
  main-dispatch
  #:port 1234
  #:listen-ip #f
  #:command-line? #t
  #:servlet-regexp #rx""
  #:servlet-path "/")
