#! /usr/bin/env racket
#lang racket/base
(require rackunit
         racket/udp
         "robot.rkt"
         "common.rkt"
         "driver-station.rkt"
         "robot-messages.rkt")

(define driver-station-host local-broadcast-host)

(define (network-test)
  (define robot-socket (udp-open-socket))
  (define driver-station-boot-socket (udp-open-socket))
  (define packet (make-bytes max-packet-size))
  (define driver-station-receive-ready-evt
    (udp-receive-ready-evt driver-station-boot-socket))
  (udp-bind! driver-station-boot-socket
             driver-station-host
             boot-port)
  (udp-send-to robot-socket
               local-broadcast-host
               boot-port
               boot-packet)
  (udp-close robot-socket)
  (let*-values ([(packet-size source-host source-port)
                 (udp-receive! driver-station-boot-socket packet)]
                [(packet) (subbytes packet 0 packet-size)])
    (udp-close driver-station-boot-socket)
    (check-equal? packet boot-packet)))
(network-test)

(define (send-boot-packet-test)
  (define driver-station-boot-socket (udp-open-socket))
  (define packet (make-bytes max-packet-size))
  (udp-bind! driver-station-boot-socket boot-port)
  (send-boot-packet)
  (let*-values ([(packet-size source-host source-port)
                 (udp-receive! driver-station-boot-socket packet)]
                [(packet) (subbytes packet 0 packet-size)])
    (udp-close driver-station-boot-socket)
    (check-equal? packet boot-packet)))
