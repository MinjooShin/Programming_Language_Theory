Racket Basic - Type Definition
==============================
- what is Type?
    - They are used to define the abstract data of anything
- The syntax for type definitions:
  ```racket
  ; type-id: abstract data
  ; variant_id: a specific kind of data in abstract data
  ; field_id: each field of the variant for taking an argument
  ; contract_expr: field type for the value of each field 
  (define-type type-id
      [variant_id1 (field_id11 contract_expr11)
                              '''
                   (fleld_id1n contract_expr1n)]
          '''
      [variant_idm (field_idm1 contract_exprm1)
                              '''
                   (fleld_idmn contract_exprmn)])
  ```
  


