#! /usr/bin/env racket
#lang racket/base
(require racket/udp
         "common.rkt")

(define (boot-packet? packet)
  (define robot-turn-on-signal #px#".*FPGA Hardware GUID: 0x.*")
  (regexp-match? robot-turn-on-signal packet))

(define (get-packet socket)
  (let ([packet (make-bytes max-packet-size)])
    (let-values
        ([(packet-size source-hostname source-port)
          (udp-receive! socket packet)])
      (values (subbytes packet 0 packet-size) source-hostname source-port))))

(define (listen-for-robot-boot socket)
  (define robot-turn-on-signal #rx".*FPGA Hardware GUID: 0x.*")
  (let*-values
      (((packet) (make-bytes max-packet-size))
       ((packet-size source-hostname source-port)
        (udp-receive! socket packet)))
    (printf "packet = ~a\n" packet)
    (printf "packet size = ~a\n" packet-size)
    (printf "source-hostname = ~a\n" source-hostname)
    (printf "source-port = ~a\n" source-port)
    (let-values (((a b) (udp-addresses socket)))
      (printf "udp addresses = ~a and ~a\n" a b))
    (if (regexp-match robot-turn-on-signal packet)
        (begin
          (printf "robot turned on!\n")
          #t)
        (listen-for-robot-boot socket))))

(provide boot-packet?
         get-packet)
