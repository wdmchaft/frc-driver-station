#! /usr/bin/env racket
#lang racket/base
(require racket/udp)

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
(define robot-host "255.255.255.255")
(define robot-port 6666)
(define robot-message #"i sent this")
(define sender (udp-open-socket robot-host robot-port))
; udp-send-to will auto-bind sender to a random local port
;  it will also auto-connect to the remote host and port
(udp-send-to sender robot-host robot-port boot-packet)
(udp-close sender)
