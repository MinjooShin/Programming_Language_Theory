Racket Basic
==
Type Definition
--
- what is Type?
    - They are used to define the abstract data of anything
- The syntax for type definition:
    - type-id: abstract data
    - variant_id: a specific kind of data in abstract data
    - field_id: each field of the variant for taking an argument
    - contract_expr: field type for the value of each field 
  ```racket
  (define-type type-id
      [variant_id1 (field_id11 contract_expr11)
                              '''
                   (fleld_id1n contract_expr1n)]
          '''
      [variant_idm (field_idm1 contract_exprm1)
                              '''
                   (fleld_idmn contract_exprmn)])
  ```

  Type Deconstruction
  --
  - why do we need type deconstruction?
      - it is useful to analyze the entire source code.
      - I(subject) love(verb) you(object).
  - The syntax for type deconstruction:
      - type-case: a kind of switch-case to return the value of the field that matches each instance
      - type-id: abstract data (like super class in Java)
      - field_id: listed up all fields for each variant
        - all fields must be listed up
      - expr: the value of the field to be returned in the field of the instance
        - no need to return all values of the field
  ```racket
  (type-case type-id expr
      [variant_id1 (field_id11 ...) expr1]
      ...
      [variant_idm (field_idm1 ...) exprm])
  ```
- QnA
    - symbol and identifier are different?
        - symbol is considered with data and starts with a single quotation mark('), but the identifier is name like variable.  


