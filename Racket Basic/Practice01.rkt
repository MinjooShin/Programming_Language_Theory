#lang plai
;Racket Basic Practice - GUI

;Type Definition

(define-type GUI
  [label    (text string?)]
  [button   (text string?)
            (enabled? boolean?)]
  [choice   (items (listof string?))
            (selected integer?)])

(label "Pick a fruit") 
(button "Ok" false)
(choice '("Apple" "Strawberry" "Banana")0)

;create identifier ch for the choice instance
(define ch (choice '("Apple" "Strawberry" "Banana")0))

;? operator: check whether ch is an instance of choice or not 
(choice? ch)

;[variant-id]-[field-id] syntax used to access the field of instance
(choice-selected ch)

;Type Deconstruction

; read-screen : GUI -> list-of-string
(define(read-screen g)
  (type-case GUI g
    [label (t) (list t)]
    [button (t e?) (list t)]
    [choice (i s) (list i s)]))

(read-screen ch)