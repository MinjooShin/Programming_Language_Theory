Function
==
- Step for modeling new language
  1. make one simple concrete expression of a new language.
  2. define concrete syntax that is, BNF.
 
- Adding functions to WAE
  - We need to define its concrete and abstract syntax first!
  - New language, AE -> WAE -> F1WAE
- How we can express simple functions in each language?
  - twice(x) = x + x
  - AE
    ```racket
    {- 20 {+ 10 10}}
    {- 20 {+ 17 17}}
    {- 20 {+ 3 3}}
    ```
  - WAE
    ```racket
    {with {x 10} {- 20 {+ x x}}}
    {with {x 17} {- 20 {+ x x}}}
    {with {x 10} {- 20 {+ x x}}}
    ```
  - **F1WAE**
    - deffun: keyword to define a function
    - twice: function name
    - x(first): parameter
    - {+ x x}: function body
    - {twice 10}: function call (or function application)
    - 10: actual argument
    ```racket
    {deffun {twice x} {+ x x}}
    {twice 10}
    ```
- F1WAE: Concrete Syntax
  - deffun: keyword
  - id(first): function name
  - id(second): parameter name
  - <F1WAE>: function body
    - It must be an arithmetic expression
  - {<id> <F1WAE>}: function call
  ```racket
  <FunDef> ::= {deffun {<id> <id>} <F1WAE>}
  <F1WAE> ::= <num>
            |{+ <F1WAE> <F1WAE>}
            |{- <F1WAE> <F1WAE>}
            |{with {<id> <F1WAE>} <F1WAE>}
            |<id>
            |{<id> <F1WAE>}
  ```
- F1WAE: Abstract Syntax
  - We separate <FunDef> and <F1WAE> parts in abstract syntax Because separate them in BNF.
  - app: function application
  - (ftn symbol?): function name part
  - (arg F1WAE?): argument value part
  ```racket
  (define-type FunDef
    [fundef (fun-name symbol?)
            (arg-name symbol?)
            (body F1WAE?)])

  (define-type F1WAE
    [num (n number?)]
    [add (lhs F1WAE?) (rhs F1WAE?)]
    [sub (lhs F1WAE?) (rhs F1WAE?)]
    [with (name symbol?) (named-expr F1WAE?) (body F1WAE?)]
    [id (name symbol?)]
    [app (ftn symbol?) (arg F1WAE?)])
  ```

- F1WAE: Parser
  - As explained above, we need two parsers.
  - Concrete code: (list 'deffun (list f x) b) -> Abstract code: (fundef f x (parse b)) 
  ```racket
  ;parse-fd: sexp -> FunDef
  (define (parse-fd sexp)
    (match sexp
      [(list 'deffun (list f x) b) (fundef f x (parse b))]))
  
  ; parse: sexp -> F1WAE
  (define (parse sexp)
    (match sexp
      [(? number?) (num sexp)]
      [(list '+ l r) (add (parse l) (parse r))]
      [(list '- l r) (sub (parse l) (parse r))]
      [(list 'with (list i v) e) (with i (parse v) (parse e))]
      [(? symbol?) (id sexp)]
      [(list f a) (app f (parse a))]
      [else (error 'parse "bad syntax: ~a" sexp)])) 
   
  ```
- F1WAE: Interpreter
    ```racket
    (app 'identity (num 8))
    ```
    - if we don't have function definition, our interpreter can't produce result above application.
    - Interpreter must have function definition
    - Also, we need second parameter for function definition
    - test case: (test (interp (add (num 1) (num 1)) list (fundef 'f 'x (add (id 'x) (num 3)))) 2)
      - function name: f
      - function parameter: x
      - entire body: (add (id 'x) (num 3))
      - Why actual result is 2?
        - We didn't call any function as it is function definition.
        - test case: (test (interp (app 'f (num 1)) (list (fundef 'f 'x (add (id 'x) (num 3)))) 4)
  ```racket
  ;interp: F1WAE list-od-FuncDef -> number
  (define (interp f1wae fundefs)
          (type-case F1WAE f1wae
            [num (n) n]
            [add (l r) (+ (interp l | fundefs) (interp r | fundefs))]
            [sub (l r) (- (interp l | fundefs) (interp r | fundefs))]
            [with (x i b) (interp (subst b x (interp i fundefs)) fundefs)]
            [id (s) (error 'interp "free identifier")]
            [app (f a) (local
                          [(define a_fundef (lookup-fundef f fundefs))]
                          (interp (subst (fundef-body a_fundef)
                                          (fundef-arg-name a_fundef)
                                          (interp a fundefs)) fundefs))]))

  ; [contract] subst: F1WAE symbol number -> F1WAE
  (define (subst f1wae idtf val)
  	(type-case F1WAE f1wae
  		[num	(n)		f1wae]
  		[add	(l r) 		(add (subst l idtf val) (subst r idtf val))]
  		[sub		(l r)	 	(sub (subst l idtf val) (subst r idtf val))]
  		[with	(i v e) 	(with i (subst v idtf val) (if (symbol=? i idtf) e
  									(subst e idtf val)))]
  		[id		(s) 		(if (symbol=? s idtf) (num val) f1wae)]
  		[app	(f a)		(app f	(subst a idtf val))]))
  
    ;lookup-fundef: symbol list-of-FunDef -> FunDef
    (define (lookup-fundef name fundefs)
      cond
        [(empty? fundefs)
            (error 'lookup-fundef "unknown function")]
        [else
          (if (symbol=? name (fundef-fun-name (first fundefs)))
                (first fundefs)
                (lookup-fundef name (rest fundefs)))])

  ```
  - a(argument part) is arithmetic expression
  - in fundefs part, we have two function
  - lookup-fundef: symbol list-of-FunDef -> FunDef
  - local: define independent logical area
  - a_fundef identifier: kinds of instance
  - f: function name
  - (interp ...): function body itself 
  - (define a_fundef (lookup-fundef f fundefs)): create function definition instance for find function name
  - substitution: function body contain parameter name, we have to replaced parameter name with actual argument value, target expression is function body we interest function
  - fundef-arg-name: argument of function -> actual value
  - lookup function: it is finding interest function given name of function
  - 만약 너가 흥미있는 함수가 정의되어 있지 않으면 에러 발생

QnA
--

