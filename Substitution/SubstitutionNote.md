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
  -  Definition (Substitution)
    - To substitute identifier 'x' in '{+ x {with {y 3} x}}' with the expression 5, replace all bound instances of 'x' and replace all free instances of 'x' in '{+ x {with {y 3} x}}' with 5.
    ```racket
    {with {x 5} {+ x {with {y 3} x}}}
    ; after replacing all the identifiers 'x' -> the value is 10
    {with {x 5} {+ 5 {with {y 3} 5}}} 
    ```
- Find Bound/Binding/Free instances and scopes of binding identifiers
  - Free identifier: 정의만 되어 있는 경우
  - Binding identifier: 정의되어 있고, 초기화된 경우
  - Bound identifier: 정의되어 있고, 초기화된 identifier를 사용하는 경우
  - Example1:
    - First 'x' -> binding identifier (identifier 값이 5로 초기화됨)
    - Second 'x' -> bound identifier  (5로 초기화된 identifier를 덧셈에 사용함)
    - Third 'x' -> bound identifier
      - '{with {y x} x}' 범위에서는 x가 정의되지 않았기 때문에 free identifier이지만, 전체 범위에서는 x는 5로 초기화되었기 때문에 bound identifier임
  - Example2:
    - First 'x' -> binding identifier
    - Second 'x' -> bound identifier
    - Third 'x' -> binding identifier
      - The third identifier has the same name as the first identifier but, a different identifier.
    - Fourth 'x' -> bound identifier in scope with '{with {x {+ x 1}} x}'
    - Fifth 'x' -> bound identifier
      - Fifth identifier는 third identifier 범위에 존재하기 때문에 third identifier 값이 fifth identifier에 bound됨    
  ```racket
  ; Example1
  {with {x 5} {+ x {with {y x} x}}}
  ; Example2
  {with {x 5} {+ x {with {x {+ x 1}} x}}}
  ```
