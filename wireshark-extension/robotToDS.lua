-- create myproto protocol and its fields
p_r2d = Proto ("robotToDS","Robot To Driver Station Protocol")
local f_control = ProtoField.uint8("robotToDS.command", "Control", base.HEX)
local f_battery = ProtoField.uint16("robotToDS.battery", "Battery", base.HEX)
local f_output  = ProtoField.uint8("robotToDS.output", "Digital Outputs", base.BIN)
local f_unknown_1 = ProtoField.bytes("robotToDS.unknown1", "Unknown 1")
local f_team    = ProtoField.uint16("robotToDS.team", "Team Number", base.DEC)
local f_mac     = ProtoField.bytes("robotToDS.mac", "Mac Address")
local f_unknown_2 = ProtoField.bytes("robotToDS.unknown2", "Unknown 2")
local f_packet  = ProtoField.uint16("robotToDS.packet", "Packet Index", base.DEC)
local f_high    = ProtoField.bytes("robotToDS.high", "High End Data")
local f_crc     = ProtoField.uint32("robotToDS.crc", "CRC Checksum")

p_r2d.fields = {f_control, f_battery, f_output, f_unknown_1, f_team, f_mac, f_unknown_2, f_packet, f_high, f_crc}

function bit(p)
  return 2 ^ (p - 1)
end

function hasbit(x, p)
  return x % (p + p) >= p       
end

function p_r2d.dissector (buf, pkt, root)
  if buf:len() < 1024 then return end
  pkt.cols.protocol = p_r2d.name

  subtree = root:add(p_r2d, buf(0))
  
  val = buf(0,1):uint()
  ctrl = subtree:add(f_control, buf(0,1))
  ctrl:add("Reset:         " .. (hasbit(val, bit(7)) and "Set" or "Unset"))
  ctrl:add("EStop:         " .. (hasbit(val, bit(6)) and "Set" or "Unset"))
  ctrl:add("Enabled:       " .. (hasbit(val, bit(5)) and "Set" or "Unset"))
  ctrl:add("Autonomous:    " .. (hasbit(val, bit(4)) and "Set" or "Unset"))
  ctrl:add("Unknown:       " .. (hasbit(val, bit(3)) and "Set" or "Unset"))
  ctrl:add("Resync:        " .. (hasbit(val, bit(2)) and "Set" or "Unset"))
  ctrl:add("CRio Checksum: " .. (hasbit(val, bit(1)) and "Set" or "Unset"))
  ctrl:add("FPGA Checksum: " .. (hasbit(val, bit(0)) and "Set" or "Unset"))
  
  batt_v = buf(1,1):uint()
  batt_mv = buf(2,1):uint()
  batt = subtree:add(f_battery, buf(1,2))
  batt:add("Volts: "..batt_v)
  batt:add("Milivolts: "..batt_mv)
  
  val = buf(3,1):uint()
  out = subtree:add(f_output, buf(3, 1))
  out:add("Output 1: " .. (hasbit(val, bit(0)) and "Set" or "Unset"))
  out:add("Output 2: " .. (hasbit(val, bit(1)) and "Set" or "Unset"))
  out:add("Output 3: " .. (hasbit(val, bit(2)) and "Set" or "Unset"))
  out:add("Output 4: " .. (hasbit(val, bit(3)) and "Set" or "Unset"))
  out:add("Output 5: " .. (hasbit(val, bit(4)) and "Set" or "Unset"))
  out:add("Output 6: " .. (hasbit(val, bit(5)) and "Set" or "Unset"))
  out:add("Output 7: " .. (hasbit(val, bit(6)) and "Set" or "Unset"))
  out:add("Output 8: " .. (hasbit(val, bit(7)) and "Set" or "Unset"))
  
  subtree:add(f_unknown_1, buf(4, 4))
  subtree:add(f_team, buf(8, 2))
  subtree:add(f_mac, buf(10,6))
  subtree:add(f_unknown_2, buf(16, 14))
  subtree:add(f_packet, buf(30,2))
  subtree:add(f_high, buf(32, 988))
  subtree:add(f_crc, buf(1020, 4))
  
end

-- Initialization routine
function p_r2d.init()
end

local tcp_dissector_table = DissectorTable.get("udp.port")
dissector = tcp_dissector_table:get_dissector(1150)
tcp_dissector_table:add(1150, p_r2d)