Substitution
==
- Motivation: why do we need substitution?
  - Several expressions are repeated
    ```racket
    {+ 5 5}
    {+ {+ 5 5} {+ 5 5}}
    ```   
    - It can make a mistake and evaluating them wastes computational cycles
  - Another repeated expression in a more familiar language
    ```c
    Int totalSum = (1+2+3+4+5+6+7+8+9+10) + (1+2+3+4+5+6+7+8+9+10) + (1+2+3+4+5+6+7+8+9+10);
    ```
    - Sum from 1 to 10 is repeated three times to get totalSum, So we can rewrite totalSum by using partialSum.
    ```c
    Int partialSum = 1+2+3+4+5+6+7+8+9+10;
    Int totalSum = partialSum + partialSum + partialSum;
    ```
    - Computational benefit: partialSum is calculated just once.
- Identifiers
  - Used to avoid this redundancy
  - Name/identify the value of an expression
  - Reuse its name in place of a larger computation
  - Similar to variables, but variables imply the **value of the identifier can change** 
    - Variable: A variable is a named storage location for data
    - Identifier: An identifier is a name used to uniquely label programming elements like variables, and functions.
  - Identifier in BNF:
  ```
  <id> ::= x, y, plus, factorial, swap, interp,...
  or
  <id> ::= <initial> <subsequent>* | + | - | ...
  <initial>	::= <letter> | ! | $ | % | & | * | : | < | = | > | ? | ~ | _ | ^
  <subsequent> ::= <initial> | <digit> | . | + | -
  <letter> ::= a | b | … | z
  <digit> ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 
  ```
  - **Binding Identifier & Bound identifier (instance)**
    - Example1
      - first 'x': binding identifier
      - second, third: bound identifier
    - Example2
      - 'y': error -> free identifier
        - It is a free identifier because it is an undefined identifier.
    - Example3
      - Generally, in various programming languages, we can define variables with the same name, but it is in different scopes.
        - Priority: inner scope -> outer scope
    - Example4
      - There is a no 'x' identifier so, 'x' in outer scope is used.
  ```racket
  ; Example1 
  {with {x {x 1 2}} {+ x x}}
  ; Example2
  {with {x {+ 1 2}} {+ x y}}
  ; Example3
  {with {x {+ 1 2}} {with {x {- 4 3}} {+ x x}}} ;2
  ;Example4
  {with {x {+ 1 2}} {with {y {- 4 3}} {+ x x}}} ;6
  ```
- **'with' with arithmetic expressions**
  - WAE in BNF
  ```
  <WAE> ::= <num>
          | {+ <WAE> <WAE>}
          | {- <WAE> <WAE>}
          | {with {<id> <WAE>} <WAE>}
          | <id>
  ```
  - Define type WAE
    - with
      - name: identifier
      - named-expr: expression of values for identifier
      - body: actual expression
  ```racket
  (define-type WAE
    [num (n number?)]
    [add (lhs WAE?) (rhs WAE?)]
    [sub (lhs WAE?) (rhs WAE?)]
    [with (name symbol?) (named-expr WAE?) (body WAE?)]
    [id (name symbol?)])
  ```
  - implement a parser for WAE
  ```racket
  ; [contract] parse: sexp -> WAE
  ; [purpose] to convert s-expression into WAE
  (define (parse sexp)
    (match sexp
      [(? number?) (num sexp)]
      [(list '+ l r) (add (parse l) (parse r))]
      [(list '- l r) (sub (parse l) (parse r))]
      [(list 'with (list i v) e) (with i (parse v) (parse e))]
      [(? symbol?) (id sexp)]
      [else (error 'parse "bad syntax:~a" sexp)]
  ```
  - How to deal with identifiers in the interpreter?
    - Defining Substitution
      - Definition 1 (Substitution)
        - To substitute the identifier 'x' in the expression, replace all identifiers in the body that have the name 'x'.
        ```
        {with {x 5} {+ x x}} -> {with {x 5} {+ 5 5}}
        ```
