Recursion
==
- Using existing syntax
  - We do not need to significantly update our interpreter.
  - Positive: we can have a lightweight interpreter.
  - Negative: the developer feels not convenient.
  ```racket
    {with {fac {with {facX {fun {facY}
     {with {fac {fun {x}
     {{facY facY} x}}}
     {fun {n}
     {if0 n
     1
     {* n {fac {- n 1}}}}}}}}
     {facX facX}}}
     {fac 10}}
  ```
- Adding new syntax for recursion
  - We need to update our interpreter to support this syntax. 
  - Positive: the developer feels it is easy to write the code.
  - Negative: The interpreter may be heavier than no updated interpreter before.
  ```racket
    {rec {fac {fun {n}
     {if0 n
     1
     {* n {fac {- n 1}}}}}} {fac 10}}
  ```
  
RCFAE: Concrete Syntax
- The recursion function can also be implemented with the phrase with, but it is too complicated.
- **New specific grammar for recursion**
  - Two new syntaxes:
    - if0: base condition for returning specific value  
    - rec: for handling recursive function  
      - id: name for recursive function
      - <RCFAE> (1): function definition
      - <RCFAE> (2): first recursive function call
  ```
  <RCFAE> ::= <num>
   | {+ <RCFAE> <RCFAE>}
   | {- <RCFAE> <RCFAE>}
   | <id>
   | {fun {<id>} <RCFAE>}
   | {<RCFAE> <RCFAE>}
   | {if0 <RCFAE> <RCFAE> RCFAE>}
   | {rec {<id> <RCFAE>} <RCFAE>}
  ```

Example
  ```racket
  {rec {count {fun {n} {if0 n 0 {+ 1 {count {- n 1}}}}}} {count 8}}
  ```
  1. Call the first recursive function call
  => {count 8}
  2. Call the second recursive function call with parameter 7
  => {+ 1 {count {- n 1}}} ⇒ {+ 1 {count 7}}
  3. Call the third recursive function call with parameter 6
  => {+ 1 {+ 1 {count 6}}}
  N. When n becomes a zero, return the 0(true branch in if0 condition)
  => {+ 1 {+ 1 {+ 1 {+ 1 {+ 1 {+ 1 {+ 1 {+ 1 {count 0}}}}....}
  => {+ 1 {+ 1 {+ 1 {+ 1 {+ 1 {+ 1 {+ 1 {+ 1 0}}}....} 
  => …
  => 8

RCFAE abstract syntax
  - name (recursive function name): count
  - named-expr (function definition): {fun {n} {if0 n 0 {+ 1 {count {- n 1}}}}}
  - fst-call (first function call): {count 8}
  ```racket
  (define-type RCFAE
     [num (n number?)]
     [add (lhs RCFAE?) (rhs RCFAE?)]
     [sub (lhs RCFAE?) (rhs RCFAE?)]
     [id (name symbol?)]
     [fun (param symbol?) (body RCFAE?)]
     [app (fun-expr RCFAE?) (arg-expr RCFAE?)]
     [if0 (test-expr RCFAE?)
     (then-expr RCFAE?) (else-expr RCFAE?)]
     [rec (name symbol?) (named-expr RCFAE?) (fst-call RCFAE?)])
  ```
Implementing RCFAE interpreter
  - We are implementing two parts: if0, rec
  ```racket
 ; interp : RCFAE DefrdSub -> RCFAE-Value
  (define (interp rcfae ds)
   (type-case RCFAE rcfae
     [num (n) (numV n)]
     [add (l r) (num+ (interp l ds) (interp r ds))]
     [sub (l r) (num- (interp l ds) (interp r ds))]
     [id (name) (lookup name ds)]
     [fun (param body-expr) (closureV param body-expr ds)]
     [app (f a) (local [(define ftn (interp f ds))]
     (interp (closureV-body ftn)
     (aSub (closureV-param ftn)
     (interp a ds)
     (closureV-ds ftn))))]
     [if0 (test-expr then-expr else-expr) ...]
     [rec (bound-id named-expr fst-call) ...]))
  ```
**if0 condition**
  - Abstract Syntax
    - If test-expr is 0, the next step executed is the then-expr part otherwise, else-expr.
    ```
    [if0 (test-expr RCFAE?) (then-expr RCFAE?) (else-expr RCFAE?)]
    ```
  - Interpreter
    - We have to check whether the test-expr is zero or not and whether the type of value is RCFAE value type or not because the interpreter returns the RCFAE-value type.
    - So, we should implement a helper function, numzero?
    ```racket
    [if0 (test-expr then-expr else-expr)
         (if (numzero? (interp test-expr ds))
         (interp then-expr ds)
         (interp else-expr ds))]

    ;numzero?: RCFAE-Value -> boolean
    (define (numzero? n) (zero? (numV-n n)))
    ```

**rec**
  - Interpreter
    ```racket
    ; interp : RCFAE DefrdSub -> RCFAE-Value
    (define (interp rcfae ds)
     (type-case RCFAE rcfae
     …
     [rec (bound-id named-expr fst-call)
     (interp fst-call
       (aSub bound-id
         (interp named-expr ds)
         ds))]
    ```
    - Problem: We can't interpret the deferred substitution cache because the bound-id is used in name-expr.
    - Solution: we can create another type of cache only for the recursion.
    - New type for the recursion cache
     ```racket
        RCFAE: DefrdSub
        (define-type DefrdSub
         [mtSub]
         [aSub (name symbol?)
               (value RCFAE-Value?)
               (ds DefrdSub?)]
         [aRecSub (name symbol?)
                  (value-box (box/c RCFAE-Value?))
                  (ds DefrdSub?)])
        (define-type RCFAE-Value
         [numV (n number?)]
         [closureV (param Symbol?) (body RCFAE?) (ds DefrdSub?)])
      ```
      - aRecSub uses a box for updating our cache, unlike aSub.
        - Because we have to know binding information which is not created yet.
        - We just create empty binding information(outline) first. it is actually a cache for recursion but we don't know about bounded value.
        - That is when we create the actual cache then we update this area later.
        - So, currently, our binding information contains incorrect information because it is empty.
        - Later, when we actually conduct binding id we update the empty part.
    ```racket
    ; interp : RCFAE DefrdSub -> RCFAE-Value
    (define (interp rcfae ds)
      (type-case RCFAE rcfae
        ...
        [rec (bound-id named-expr fst-call)
          (local [(define value-holder (box (numV 198)))
                  (define new-ds (aRecSub bound-id
                                          value-holder
                                          ds))]
            ... (interp named-expr new-ds)
            ... (interp fst-call new-ds) ...]))
    ```
    - aRecSub: name of the cache we create
    - bound-id: count
    - value-holder: dummy value
    - name-expr: function body(function definition)
    - new-ds: new deferred substitution cache for function definition
      - Function contains the recursive function name.
      - We have to access the new deferred substitution cache, not ds.
      - if we provide just the same ds, it does not contain any binding information for the recursive function.
    - Why do we need a Dummy value?
      - Before creating our cache we need to create binding information.
      - So, we can put the dummy value and any number is ok.
- Final Interpreter
  ```racket
  ; interp : RCFAE DefrdSub -> RCFAE-Value
  (define (interp rcfae ds)
    (type-case RCFAE rcfae
      ...
      [fun (param body-expr) (closureV param body-expr ds)]
      ...
      [rec (bound-id named-expr fst-call)
        (local [(define value-holder (box (numV 198)))
                (define new-ds (aRecSub bound-id
                                        value-holder ds))]
          (begin
            (set-box! value-holder (interp named-expr new-ds))
            (interp fst-call new-ds)))]))
  ```

- Updating the lookup function
  ```racket
  ; lookup : symbol DefrdSub -> RCFAE-Value
  (define (lookup name ds)
    (type-case DefrdSub ds
      [mtSub () (error ’lookup "free variable")]
      [aSub (sub-name val rest-ds)
            (if (symbol=? sub-name name)
                val
                (lookup name rest-ds))]
      [aRecSub (sub-name val-box rest-ds)
               (if (symbol=? sub-name name)
                   (unbox val-box)
                   (lookup name rest-ds))]))
  ```

Example Run 
```racket
  [rec (f fun-expr fst-call)
    (local [(define value-holder (box (numV 198)))
            (define new-ds (aRecSub f value-holder ds))]
      (begin
        (set-box! value-holder (interp fun-expr new-ds))
        (interp fst-call new-ds)))]
  
  (run '{rec {count {fun {n} {if0 n 0 {+ 1 {count {- n 1}}}}}}
          {count 8}} (mtSub))
```
- Execution Flow
  1. rec branch
    - f = count
    - fun-expr = {fun {n} {if0 n 0 {+ 1 {count {- n 1}}}}}}
    - fst-call = {count 8}
    - value-holder = [numV 198]
    - new-ds = (aRecSub 'count value-holder (mtSub))
      => We got the new deferred substitution cache for recursion with the current value-holder as a dummy value.
    - (interp fun-expr new-ds) = closureV
  3. fun branch
    - (interp fun-expr new-ds) = (closureV 'n (if0 n 0 (+ 1 (count (- n 1)))) new-ds)
    - value-holder = [(closureV 'n '{if0 n 0 {+ 1 {count {- n 1}}}} new-ds)]
  4. app branch
