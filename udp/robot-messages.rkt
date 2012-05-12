#lang racket/base

; 0x0d 0x0a == carriage-return, line-feed == windows newline
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

(provide boot-packet)
