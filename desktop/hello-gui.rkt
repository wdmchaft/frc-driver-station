#! /usr/bin/env racket
#lang racket/gui

(define frame (new frame% [label "Example"]))

(define msg (new message% [parent frame] [label "No events so far..."]))

(new button% [parent frame]
     [label "Click Me"]
     (callback (lambda (button event)
                 (send msg set-label "Button click"))))
; Derive a new canvas (a drawing window) class to handle events
(define my-canvas%
  (class canvas% ; The base class is canvas%
    ; Define overriding method to handle mouse events
    (define/override (on-event event)
      (send msg set-label "Canvas mouse"))
    ; Define overriding method to handle keyboard events
    (define/override (on-char event)
      (send msg set-label "Canvas keyboard"))
    ; Call the superclass init, passing on all init args
    (super-new)))
 
; Make a canvas that handles events in the frame
(new my-canvas% [parent frame])
(send frame show #t)
