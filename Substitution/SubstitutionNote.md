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
 
