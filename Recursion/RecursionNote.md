  
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
    - if0 condition: base condition for returning specific value  
    - rec: for handling recursive function  
      - id: name for recursive function
      - <RCFAE> (1): function definition
      - <RCFAE> (2): first recursive function call
  <RCFAE> ::= <num>
   | {+ <RCFAE> <RCFAE>}
   | {- <RCFAE> <RCFAE>}
   | <id>
   | {fun {<id>} <RCFAE>}
   | {<RCFAE> <RCFAE>}
   | **{if0 <RCFAE> <RCFAE> RCFAE>}**
   | **{rec {<id> <RCFAE>} <RCFAE>}**

Example

RCFAE abstract syntax

Implementing RCFAE interpreter

Example Run

Possible Exam Questions (at least two questions with answers):



