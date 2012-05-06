#! /usr/bin/env racket
#lang racket/base
(require racket/udp)

(define broadcast-ip "255.255.255.255")
(define robot-port 6666)
(define robot-message #"i sent this")
(define sender (udp-open-socket broadcast-ip robot-port))
; udp-send-to will auto-bind sender to a random local port
;  it will also auto-connect to the remote host and port
(udp-send-to sender broadcast-ip robot-port robot-message)
(udp-close sender)
