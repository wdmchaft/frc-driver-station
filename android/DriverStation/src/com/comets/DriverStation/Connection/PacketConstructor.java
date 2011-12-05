package com.comets.DriverStation.Connection;

import java.io.*;

public class PacketConstructor
{
	public void CopyToStream(DSToRobot packet, BufferedWriter s)
	{
		try
		{
			WriteInt16(s, packet.packetIndex);
			WriteInt8(s, packet.control);
			WriteInt8(s, packet.dsDigitalIn);
			WriteInt16(s, packet.teamID);
			WriteInt8(s, packet.ds_Alliance);
			WriteInt8(s, packet.ds_Position);
			for(int i=0;i<4;i++)
			{
				for(int j=0;j<6;j++)
					WriteInt8(s,packet.Joysticks[i][j]);
				WriteInt16(s, packet.JButtons[i]);
			}
			for(int i=0;i<4;i++)
				WriteInt16(s, packet.AnalogIn[i]);
			WriteInt64(s, packet.cRIOChecksum);
			WriteInt32(s, packet.FPGAChecksum0);
			WriteInt32(s, packet.FPGAChecksum1);
			WriteInt32(s, packet.FPGAChecksum2);
			WriteInt32(s, packet.FPGAChecksum3);
			WriteByteArray(s, packet.versionData, 8);
			WriteByteArray(s, packet.highEndData, 938);
			WriteInt32(s, packet.CRC);
		}
		catch(Exception ex)
		{
			
		}
	}
	
	public void ReadFromStream(RobotToDS base, BufferedReader s)
	{
		try
		{
			base.control = ReadInt8(s);
			base.batteryVolts = ReadInt8(s);
			base.batteryMV = ReadInt8(s);
			base.dio = ReadInt8(s);
			ReadByteArray(s, base.unknown1, 4);
			base.teamNumber = ReadInt16(s);
			ReadByteArray(s, base.macAddr, 6);
			ReadByteArray(s, base.unknow2, 14);
			base.packetCount = ReadInt16(s);
			ReadByteArray(s, base.highData, 988);
			base.crc = ReadInt32(s);
		}
		catch(Exception ex)
		{
			ex.printStackTrace();
		}
	}
	
	public byte ReadInt8(BufferedReader r) throws IOException
	{
		return (byte)r.read();
	}
	
	public short ReadInt16(BufferedReader r) throws IOException
	{
		byte b1 = (byte)r.read();
		byte b2 = (byte)r.read();
		return (short)((b2 << 8) + b1);
	}
	
	public int ReadInt32(BufferedReader r) throws IOException
	{
		byte b1 = (byte)r.read();
		byte b2 = (byte)r.read();
		byte b3 = (byte)r.read();
		byte b4 = (byte)r.read();
		return (b4 << 24) + (b3 << 16) + (b2 << 8) + b1;
	}
	public void ReadByteArray(BufferedReader r, byte[] dest, int length) throws IOException
	{
		for(int i=0;i<length;i++)
		{
			dest[i] = ReadInt8(r);
		}
	}
	public void WriteInt8(BufferedWriter r, byte value) throws IOException
	{
		r.write(value);
	}
	
	public void WriteInt16(BufferedWriter r, short value) throws IOException
	{
		for(int i=0;i<2;i++)
			r.write((byte)((value >> (8 * i)) & 0xFF));
	}
	
	public void WriteInt32(BufferedWriter r, int value) throws IOException
	{
		for(int i=0;i<4;i++)
			r.write((byte)((value >> (8 * i)) & 0xFF));
	}
	
	public void WriteInt64(BufferedWriter r, long value) throws IOException
	{
		for(int i=0;i<8;i++)
			r.write((byte)((value >> (8 * i)) & 0xFF));
	}
	public void WriteByteArray(BufferedWriter r, byte[] src, int length) throws IOException
	{
		for(int i=0;i<length;i++)
			r.write(src[i]);
	}
}

class DSToRobot
{
	public DSToRobot(){}
	
	short packetIndex;
	byte control;
	byte dsDigitalIn;
	short teamID;
	
	byte ds_Alliance;
	byte ds_Position;
	
	byte[][] Joysticks = new byte[4][6];
	short[] JButtons = new short[4];
	
	short[] AnalogIn = new short[4];
	
	long cRIOChecksum;
	int FPGAChecksum0;
	int FPGAChecksum1;
	int FPGAChecksum2;
	int FPGAChecksum3;

	byte[] versionData = new byte[8];

	byte[] highEndData = new byte[938];
	int CRC;
}

class RobotToDS
{
	public RobotToDS(){}
	byte control;
	byte batteryVolts;
	byte batteryMV;
	byte dio;
	byte[] unknown1 = new byte[4];
	short teamNumber;
	byte[] macAddr = new byte[6];
	byte[] unknow2 = new byte[14];
	short packetCount;
	byte[] highData = new byte[988];
	int crc;
}

//Original Pack Defs from iPhone version

/*
 * 
uint16_t packetIndex;

uint8_t control;
uint8_t dsDigitalIn;
uint16_t teamID;

char dsID_Alliance;
char dsID_Position;

union {
        int8_t stick0Axes[6];
        struct {
                int8_t stick0Axis1;
                int8_t stick0Axis2;
                int8_t stick0Axis3;
                int8_t stick0Axis4;
                int8_t stick0Axis5;
                int8_t stick0Axis6;
        }axis;
}stick0;
uint16_t stick0Buttons;         // Left-most 4 bits are unused

union {
        int8_t stick1Axes[6];
        struct {
                int8_t stick1Axis1;
                int8_t stick1Axis2;
                int8_t stick1Axis3;
                int8_t stick1Axis4;
                int8_t stick1Axis5;
                int8_t stick1Axis6;
        }axis;
}stick1;
uint16_t stick1Buttons;         // Left-most 4 bits are unused

union {
        int8_t stick2Axes[6];
        struct {
                int8_t stick2Axis1;
                int8_t stick2Axis2;
                int8_t stick2Axis3;
                int8_t stick2Axis4;
                int8_t stick2Axis5;
                int8_t stick2Axis6;
        }axis;
}stick2;
uint16_t stick2Buttons;         // Left-most 4 bits are unused

union {
        int8_t stick3Axes[6];
        struct {
                int8_t stick3Axis1;
                int8_t stick3Axis2;
                int8_t stick3Axis3;
                int8_t stick3Axis4;
                int8_t stick3Axis5;
                int8_t stick3Axis6;
        }axis;
}stick3;
uint16_t stick3Buttons;         // Left-most 4 bits are unused

//Analog inputs are 10 bit right-justified
uint16_t analog1;
uint16_t analog2;
uint16_t analog3;
uint16_t analog4;

uint64_t cRIOChecksum;
uint32_t FPGAChecksum0;
uint32_t FPGAChecksum1;
uint32_t FPGAChecksum2;
uint32_t FPGAChecksum3;

char versionData[8];

uint8_t highEndData[938];
uint32_t CRC;
};

struct RobotDataPacket
{
uint8_t control;
uint8_t batteryVolts;
uint8_t batteryMV;
union {
        uint8_t dio;
        struct {
                uint8_t out1 : 1;
                uint8_t out2 : 1;
                uint8_t out3 : 1;
                uint8_t out4 : 1;
                uint8_t out5 : 1;
                uint8_t out6 : 1;
                uint8_t out7 :1;
                uint8_t out8 :1;
        }outputs;
}digitalOutput;
uint8_t unknown1[4];
uint16_t teamNumber;
char macAddr[6];
uint8_t unknow2[14];
uint16_t packetCount;
uint8_t highData[988];
uint32_t crc;
};*/
