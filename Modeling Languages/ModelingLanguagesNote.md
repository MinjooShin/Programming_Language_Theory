Modeling Languages
==
- **Big Picture**
  - By writing an interpreter, we can understand the language!
  - Interpreter can be converted into a compiler.
![image](https://github.com/MinjooShin/Programming_Language_Theory/assets/74174008/a75db489-a524-484f-af48-d6995b5d3226)

- Which one is most significant to learn PLT? 
  - Semantics is the most significant part because the primary role of language is communication.
- Interpreter Semantics
  - We focus on interpreter semantics to model and interpret new languages to understand programming language theory.
- Modeling Syntax
  - Concrete Syntax(=expression)
    - 3 + 4 (infix)
    - 3 4 + (postfix)
    - (+ 3 4) (parenthesized prefix)
  - Abstract Syntax(=essence all other syntaxs)
    - There are different kinds of languages, but by dealing with different kinds of syntax in general form we can easily focus on our semantics.
  - 'Representation' with the 'right data definition' in Racket
    - Concrete Syntax -> Abstract Syntax: (+ 3 4) -> **(add (num 3) (num 4))**
  - Model new language **AE stands for "Arithmetic Expression"**:
    ```racket
    (define-type AE
      [num (n number?)]
      [add (lhs AE?)
           (rhs AE?)]
      [sub (lhs AE?)
           (rhs AE?)])
    ```
- Parser
  - A parser is a component in an interpreter or compiler.
  -  If C source code is compiled with the Java compiler, it produces syntax errors because each language has its own parser.
  -  So, the role of the parser identify what kinds of program code it is examining, and convert concrete syntax into abstract syntax.
  -  To convert abstract syntax, we need a clear specification of the concrete syntax of the language!
    - How to specify concrete syntax?
      - **Backus-Naur Form(BNF)**:
        - <expr>: Non-terminal, which can rewrite it as one for the things on the right-hand side
        - ::=: "Can be written as"
        - |: "one more choice"
        - <...>: literal syntax
        - Terminal, which is everything that's not non-terminal
      ```
      <expr> ::= (<expr>+<expr>)
               | (<expr>-<expr>)
               | <num>
      <num> ::= 1, 42, 17, ...
      ```
      - We can convert concrete syntax into abstract syntax and verify the abstract syntax we write using the BNF grammar of each language
      
QnA
--
  - why left-hand side and right-hand side are not number types?
    -  Each side might be num or add or sub that is, it may not be a number. So, it must be AE for all possibilities.

Keyword
--
  - Semantics: the behaviors associated with each syntax
  - Interpreter Semantics: A methodology that describes how programming languages should behave and defines how to interpret the language's statements and expressions
