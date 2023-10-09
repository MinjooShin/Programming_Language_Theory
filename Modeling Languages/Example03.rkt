#lang plai

; BNF for AE
;<AE> ::= <num>
;   |{+ <AE> <AE>}
;   |{- <AE> <AE}

; Abstract syntax
(define-type AE
  [num (n number?)]
  [add (lhs AE?) (rhs AE?)]
  [sub (lhs AE?) (rhs AE?)])

; parser for AE
(define (parse sexp)
  (cond
    [(number? sexp) (num sexp)]
    [(and (= 3 (length sexp)) (eq? (first sexp) '+))
     (add (parse (second sexp))
          (parse (third sexp)))]
    [(and (= 3 (length sexp)) (eq? (first sexp) '-))
     (sub (parse (second sexp))
          (parse (third sexp)))]
    [else (error 'parse "bad syntax: ~a" sexp)]))

; interpreter for AE
(define (interp ae)
  (type-case AE ae
    [num (n) n]
    [add (l r) (+ (interp l) (interp r))]
    [sub (l r) (- (interp l) (interp r))]))

;We can use the abstract syntax obtained by the parser
;as a parameter for interp to get the result we want.

;(parse '{+ 1 2})
(test (interp(parse {+ 1 2})) 3)