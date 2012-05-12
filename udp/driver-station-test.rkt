#! /usr/bin/env racket
#lang racket/base
(require rackunit
         racket/udp
         net/dns ; for dns-get-name and dns-find-nameserver
         mzlib/os ; for gethostname
         "common.rkt"
         "robot-messages.rkt"
         "driver-station.rkt"
         "robot.rkt")

(define nameserver (dns-find-nameserver))
(define hostname (gethostname))

(define test-port 6666)
(define driver-station-host any-host)
(define driver-station-port test-port)

(check-true (boot-packet? boot-packet))
(check-false (boot-packet? #"asdf"))

(let
    ([driver-station-socket (udp-open-socket)]
     [robot-socket (udp-open-socket)]
     [packet (make-bytes max-packet-size)])
  (udp-bind! driver-station-socket any-host boot-port)
  (udp-send-to robot-socket
               local-broadcast-host
               boot-port
               boot-packet)
  (udp-close robot-socket)
  (let-values
      ([(packet source-host source-port)
        (get-packet driver-station-socket)])
    (check-equal? packet boot-packet))
  (udp-close driver-station-socket))
