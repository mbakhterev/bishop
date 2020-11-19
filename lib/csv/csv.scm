; Оригинал взят в https://github.com/NalaGinrut/guile-csv

(define-module (csv csv)
  #:use-module (ice-9 optargs)
  #:export (make-csv-reader))

(define (csv-read-row port delimiter have-cell init-seed)
  (define (!)
    (let ((c (read-char port)))
      c))
  (define (finish-cell b seed)
    (have-cell (list->string (reverse b)) seed))
  (define (next-cell b seed)
    (state-init (!) (finish-cell b seed)))
  (define (state-init c seed)
    (cond ((eqv? c delimiter) (state-init (!) (have-cell "" seed)))
          ((eqv? c #\") (state-string (!) '() seed))
          ((eqv? c #\newline) seed)
          ((eof-object? c) seed)
          (else (state-any c '() seed))))
  (define (state-string c b seed)
    (cond ((eqv? c #\") (state-string-quote (!) b seed))
          ((eof-object? c) (error "Open double-quoted string" (list->string (reverse b))))
          (else (state-string (!) (cons c b) seed))))
  (define (state-string-quote c b seed)
    (cond ((eqv? c #\") (state-string (!) (cons c b) seed)) ; Escaped double quote.
          ((eqv? c delimiter) (next-cell b seed))
          ((eqv? c #\newline) (finish-cell b seed))
          ((eof-object? c)    (finish-cell b seed))
          (else (error "Single double quote at unexpected place." c b))))
  (define (state-any c b seed)
    (cond ((eqv? c delimiter) (next-cell b seed))
          ((eqv? c #\newline) (finish-cell b seed))
          ((eof-object? c)    (finish-cell b seed))
          (else (state-any (!) (cons c b) seed))))
  (state-init (!) init-seed))

(define (csv-read port delimiter new-row have-cell have-row init-seed)
  (let lp ((seed init-seed))
    (cond
     ((eof-object? (peek-char port)) seed)
     (else (lp (have-row (csv-read-row port delimiter have-cell (new-row seed))
                         seed))))))

(define* (make-csv-reader delimiter
                          #:key
                          (new-row (lambda x '()))
                          (have-cell cons)
                          (have-row (lambda (row rows)
                                      (cons (list->vector (reverse row)) rows)))
                          (init-seed '()))
         (lambda (port)
           (reverse
             (csv-read port delimiter new-row have-cell have-row init-seed))))
