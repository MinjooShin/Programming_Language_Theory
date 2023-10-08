#lang plai
;Racket Basic practice - Animal

;Type Definition
(define-type Animal
  (bear (num_child number?)
        (color string?))
  (giraffe (height number?)
           (name string?)
           (len_neck number?))
  (snake (lenth number?)
         (poison boolean?)))

(define myBear(bear 2 "white"))
(define myGiraffe(giraffe 200 "MJ" 100))
(Animal? myBear)
(bear? myBear)
(snake? myBear)
(bear-num_child myBear)

;Type Deconstruction
; getnumber: Animal -> list of numbers
(define (getnumber a)
  (type-case Animal a 
    [bear (n c) n c]
    [giraffe (h n l_n) (list h l_n)]
    [snake (l p?) l]))

(getnumber myBear)
(getnumber myGiraffe)