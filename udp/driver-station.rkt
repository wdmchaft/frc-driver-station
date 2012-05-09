#! /usr/bin/env racket
#lang racket/base
(require racket/udp)

(define broadcast-ip "0.0.0.0")
(define driver-station-host broadcast-ip)
(define driver-station-port 6666)
(define max-packet-size 65535)

(define (boot-packet? packet)
  (define robot-turn-on-signal #px#".*FPGA Hardware GUID: 0x.*")
  (regexp-match? robot-turn-on-signal packet))

(define (get-packet host port)
  (let ([socket (udp-open-socket)]
        [packet (make-bytes max-packet-size)])
    (udp-bind! socket host port)
    (let*-values
        ([(packet-size source-hostname source-port)
          (udp-receive! socket packet)])
      (udp-close socket)
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
        (printf "robot turned on!\n")
        (listen-for-robot-boot socket))))

;(begin
;  (define driver-station-socket (udp-open-socket))
;  (udp-bind! driver-station-socket driver-station-host driver-station-port)
;  (listen-for-robot-boot driver-station-socket)
;  (udp-close driver-station-socket))

(provide boot-packet? get-packet)
