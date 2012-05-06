#! /usr/bin/env racket
#lang racket/base
(require racket/udp)

(define broadcast-ip "0.0.0.0")
(define robot-port 6666)
(define max-packet-size 65535)

(define receiver (udp-open-socket))
(udp-bind! receiver broadcast-ip robot-port)
(let*-values
    (((packet) (make-bytes max-packet-size))
     ((packet-size source-hostname source-port)
      (udp-receive! receiver packet)))
  (printf "packet = ~a\n" packet)
  (printf "packet size = ~a\n" packet-size)
  (printf "source-hostname = ~a\n" source-hostname)
  (printf "source-port = ~a\n" source-port)
  (let-values (((a b) (udp-addresses receiver)))
    (printf "udp addresses = ~a and ~a\n" a b)))
(udp-close receiver)
