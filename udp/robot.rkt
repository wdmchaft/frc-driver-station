#! /usr/bin/env racket
#lang racket/base
(require racket/udp
         "robot-messages.rkt"
         "common.rkt")

; udp-send-to will auto-bind sender to a random local port
;  it will also auto-connect to the remote host and port
(define (send-boot-packet)
  (let ([boot-broadcast-socket (udp-open-socket)])
    (udp-send-to boot-broadcast-socket
                 local-broadcast-host
                 boot-port
                 boot-packet)
    (udp-close boot-broadcast-socket)))

(provide send-boot-packet)
