#! /usr/bin/env racket
#lang racket/base
(require rackunit
         net/dns ; for dns-get-name and dns-find-nameserver
         mzlib/os ; for gethostname
         "driver-station.rkt")

(define nameserver (dns-find-nameserver))
(define hostname (gethostname))

(define test-host "0.0.0.0")
(define test-port 6666)
(define driver-station-host test-host)
(define driver-station-port test-port)

; 0x0d 0x0a shows up in the boot packet a lot
(define da #"\15\12")
(define boot-packet
  (bytes-append
                 #"FPGA H"
   #"ardware " #"GUID: 0x"
   #"A14C11BD" #"E4BB64AE"
   #"F6A86FC5" #"2A294CD9"
   da
     #"FPGA S" #"oftware "
   #"GUID: 0x" #"A14C11BD"
   #"E4BB64AE" #"F6A86FC5"
   #"2A294CD9" da
                 #"FPGA H"
   #"ardware " #"Version:"
   #" 2012"
        #"\15\13"
          #"F" #"PGA Soft"
   #"ware Ver" #"sion: 20"
   #"12"
     da
       #"FPGA" #" Hardwar"
   #"e Revisi" #"on: 1.6."
   #"4"
    da
      #"FPGA " #"Software"
   #" Revisio" #"n: 1.6.4"
   da
     #"* Load" #"ing FRC_"
   #"JavaVM.o" #"ut: FRC_"
   #"JavaVM"
     da))

(check-true (boot-packet? boot-packet))
(check-false (boot-packet? #"asdf"))

(define (test-net)
  (let*-values ([(packet host port)
                 (get-packet driver-station-host driver-station-port)])
    (check-equal? packet boot-packet)
    ; care what remote host was, but don't know how to test
    #;(check-equal? host "192.168.1.6")
    ; don't care what remote port was
))
