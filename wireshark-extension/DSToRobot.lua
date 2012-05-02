-- create myproto protocol and its fields
p_d2r = Proto ("DSToRobot","Driver Station To Robot Protocol")

local f_packet    = ProtoField.uint16("DSToRobot.packet", "Packet Index", base.DEC)
local f_control   = ProtoField.uint8("DSToRobot.command", "Control", base.HEX)
local f_input     = ProtoField.uint8("DSToRobot.input", "Digital Input", base.BIN)
local f_team      = ProtoField.uint16("DSToRobot.team", "Team Number", base.DEC)
local f_alliance  = ProtoField.string("DSToRobot.alliance", "Team Alliance")
local f_position  = ProtoField.string("DSToRobot.position", "Team Position")
local f_joystick1 = ProtoField.bytes("DSToRobot.joystick1", "Joystick 1")
local f_js_btn1   = ProtoField.uint16("DSToRobot.jsbtn1", "Joystick 1 Buttons", base.BIN)
local f_joystick2 = ProtoField.bytes("DSToRobot.joystick2", "Joystick 2")
local f_js_btn2   = ProtoField.uint16("DSToRobot.jsbtn2", "Joystick 2 Buttons", base.BIN)
local f_joystick3 = ProtoField.bytes("DSToRobot.joystick3", "Joystick 3")
local f_js_btn3   = ProtoField.uint16("DSToRobot.jsbtn3", "Joystick 3 Buttons", base.BIN)
local f_joystick4 = ProtoField.bytes("DSToRobot.joystick4", "Joystick 4")
local f_js_btn4   = ProtoField.uint16("DSToRobot.jsbtn4", "Joystick 4 Buttons", base.BIN)
local f_analog1   = ProtoField.uint16("DSToRobot.analog1", "Analog 1", base.DEC)
local f_analog2   = ProtoField.uint16("DSToRobot.analog2", "Analog 2", base.DEC)
local f_analog3   = ProtoField.uint16("DSToRobot.analog3", "Analog 3", base.DEC)
local f_analog4   = ProtoField.uint16("DSToRobot.analog4", "Analog 4", base.DEC)
local f_crio_chk  = ProtoField.uint64("DSToRobot.crio_chk", "cRio Checksum", base.HEX)
local f_fpga_chk1 = ProtoField.uint32("DSToRobot.fpga_chk1", "FPGA Checksum 1", base.HEX)
local f_fpga_chk2 = ProtoField.uint32("DSToRobot.fpga_chk2", "FPGA Checksum 2", base.HEX)
local f_fpga_chk3 = ProtoField.uint32("DSToRobot.fpga_chk3", "FPGA Checksum 3", base.HEX)
local f_fpga_chk4 = ProtoField.uint32("DSToRobot.fpga_chk4", "FPGA Checksum 4", base.HEX)
local f_version   = ProtoField.string("DSToRobot.cersion", "Version")
local f_high      = ProtoField.bytes("DSToRobot.high", "High End Data")
local f_crc       = ProtoField.uint32("DSToRobot.crc", "CRC Checksum")

p_d2r.fields = {f_packet, f_control, f_input, f_team, f_alliance, f_position, f_joystick1, f_js_btn1, f_joystick2, f_js_btn2, f_joystick3, f_js_btn3, f_joystick4, f_js_btn4, 
			f_analog1, f_analog2, f_analog3, f_analog4, f_crio_check, f_fpga_chk1, f_fpga_chk2, f_fpga_chk3, f_fpga_chk4,
			f_version, f_high, f_crc}

function bit(p)
  return 2 ^ (p - 1)
end

function hasbit(x, p)
  return x % (p + p) >= p       
end

function p_d2r.dissector (buf, pkt, root)
  if buf:len() < 1024 then return end
  pkt.cols.protocol = p_d2r.name

  subtree = root:add(p_d2r, buf(0))
  
  subtree:add(f_packet, buf(0,2))
  
  val = buf(2,1):uint()
  ctrl = subtree:add(f_control, buf(2,1))
  ctrl:add("Reset:         " .. (hasbit(val, bit(7)) and "Set" or "Unset"))
  ctrl:add("EStop:         " .. (hasbit(val, bit(6)) and "Set" or "Unset"))
  ctrl:add("Enabled:       " .. (hasbit(val, bit(5)) and "Set" or "Unset"))
  ctrl:add("Autonomous:    " .. (hasbit(val, bit(4)) and "Set" or "Unset"))
  ctrl:add("Unknown:       " .. (hasbit(val, bit(3)) and "Set" or "Unset"))
  ctrl:add("Resync:        " .. (hasbit(val, bit(2)) and "Set" or "Unset"))
  ctrl:add("CRio Checksum: " .. (hasbit(val, bit(1)) and "Set" or "Unset"))
  ctrl:add("FPGA Checksum: " .. (hasbit(val, bit(0)) and "Set" or "Unset"))
  
  val = buf(3,1):uint()
  out = subtree:add(f_input, buf(3, 1))
  out:add("Input 1: " .. (hasbit(val, bit(0)) and "Set" or "Unset"))
  out:add("Input 2: " .. (hasbit(val, bit(1)) and "Set" or "Unset"))
  out:add("Input 3: " .. (hasbit(val, bit(2)) and "Set" or "Unset"))
  out:add("Input 4: " .. (hasbit(val, bit(3)) and "Set" or "Unset"))
  out:add("Input 5: " .. (hasbit(val, bit(4)) and "Set" or "Unset"))
  out:add("Input 6: " .. (hasbit(val, bit(5)) and "Set" or "Unset"))
  out:add("Input 7: " .. (hasbit(val, bit(6)) and "Set" or "Unset"))
  out:add("Input 8: " .. (hasbit(val, bit(7)) and "Set" or "Unset"))
  
  subtree:add(f_team, buf(4, 2))
  subtree:add(f_alliance, buf(6,1))
  subtree:add(f_position, buf(7,1))
  
  js1 = subtree:add(f_joystick1, buf(8, 6))
  js1:add(f_js_btn1, buf(14, 2))
  js1:add("Axis 1: " .. buf(8,1))
  js1:add("Axis 2: " .. buf(9,1))
  js1:add("Axis 3: " .. buf(10,1))
  js1:add("Axis 4: " .. buf(11,1))
  js1:add("Axis 5: " .. buf(12,1))
  js1:add("Axis 6: " .. buf(13,1))
  
  js2 = subtree:add(f_joystick2, buf(16, 6))
  js2:add(f_js_btn2, buf(22, 2))
  js2:add("Axis 1: " .. buf(16,1))
  js2:add("Axis 2: " .. buf(17,1))
  js2:add("Axis 3: " .. buf(18,1))
  js2:add("Axis 4: " .. buf(19,1))
  js2:add("Axis 5: " .. buf(20,1))
  js2:add("Axis 6: " .. buf(21,1))
  
  js3 = subtree:add(f_joystick3, buf(24, 6))
  js3:add(f_js_btn3, buf(30, 2))
  js3:add("Axis 1: " .. buf(24,1))
  js3:add("Axis 2: " .. buf(25,1))
  js3:add("Axis 3: " .. buf(26,1))
  js3:add("Axis 4: " .. buf(27,1))
  js3:add("Axis 5: " .. buf(28,1))
  js3:add("Axis 6: " .. buf(29,1))
  
  js4 = subtree:add(f_joystick4, buf(32, 6))
  js4:add(f_js_btn4, buf(38, 2))
  js4:add("Axis 1: " .. buf(32,1))
  js4:add("Axis 2: " .. buf(33,1))
  js4:add("Axis 3: " .. buf(34,1))
  js4:add("Axis 4: " .. buf(35,1))
  js4:add("Axis 5: " .. buf(36,1))
  js4:add("Axis 6: " .. buf(37,1))
  
  subtree:add(f_analog1, buf(40, 2))
  subtree:add(f_analog2, buf(42, 2))
  subtree:add(f_analog3, buf(44, 2))
  subtree:add(f_analog4, buf(46, 2))
  
  subtree:add(f_crio_chk, buf(48, 8))
  subtree:add(f_fpga_chk1, buf(56, 4))
  subtree:add(f_fpga_chk2, buf(60, 4))
  subtree:add(f_fpga_chk3, buf(64, 4))
  subtree:add(f_fpga_chk4, buf(68, 4))
  
  subtree:add(f_version, buf(72, 8))
  
  subtree:add(f_high, buf(80, 940))
  subtree:add(f_crc, buf(1020, 4))
  
end

-- Initialization routine
function p_d2r.init()
end

local tcp_dissector_table = DissectorTable.get("udp.port")
dissector = tcp_dissector_table:get_dissector(1110)
tcp_dissector_table:add(1110, p_d2r)