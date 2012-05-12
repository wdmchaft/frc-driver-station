#lang racket/base

(define boot-port 6666)
(define any-host "0.0.0.0")
(define local-broadcast-host "127.0.0.255")

(define max-packet-size 65535)

(provide boot-port
         any-host
         local-broadcast-host
         max-packet-size)
