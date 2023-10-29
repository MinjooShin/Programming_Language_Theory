#lang plai
;Substitution practice - WAE

;'with' keyword to define an identifier for an arithmetic expression

; WAE in BNF
;<WAE> ::= <num>
;       |{+ <WAE> <WAE>}
;       |{- <WAE> <WAE>}
;       |{with {<id> <WAE>} <WAE>}
;       | <id>

; Abstract syntax
(define-type WAE
  [num (n number?)]
  [add (lhs WAE?) (rhs WAE?)]
  [sub (lhs WAE?) (rhs WAE?)]
  [with (name symbol?)(named-expr WAE?)(body WAE?)]
  [id (name symbol?)])

;프로그램을 해석하거나 프로그램에서 변수의 유효범위를 확인하는 등의 작업을 수행하기 위해 추상 구문을 위해 데이터 구조를 정의하는 것

; WAE parser
;[contract] parse: sexp -> WAE
;[purpose] to convert s-expression into WAE
(define (parse sexp)
  (match sexp
    [(? number?) (num sexp)]
    [(list '+ l r) (add (parse l)(parse r))]
    [(list '- l r) (sub (parse l)(parse r))]
    [(list 'with (list i v) e) (with i (parse v)(parse e))]
    [(? symbol?) (id sexp)]
    [else (error 'parse "bad syntax:~a" sexp)]))

;(test (parse '{with {x 5} {+ 8 2}}) (with 'x (num 5)(add (num 8)(num 2))))
;(test (parse '{with {x 5} {+ x x}}) (with 'x (num 5)(add (id 'x)(id 'x))))

; WAE interpreter
;interp: WAE -> number
(define (interp wae)
        (type-case WAE wae
          [num (n) n]
          [add (l r) (+ (interp l) (interp r))]
          [sub (l r) (- (interp l) (interp r))]
          [with (i v e)(interp (subst e i (interp v)))]
          [id(s) (error 'interp "free identifier")]))


(test (interp (with 'x (num 5) (add (id 'x) (id 'x)))) 10)