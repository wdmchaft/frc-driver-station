package com.comets.DriverStation.Connection;

import java.net.*;
import java.io.*;

public class RobotConnection
{
	private static RobotConnection sharedConnection = null;
	
	public static RobotConnection GetConnection()
	{
		if(sharedConnection == null)
			sharedConnection = new RobotConnection();
		
		return sharedConnection;
	}
	
	private RobotToDS RtoDSPacket;
	private DSToRobot DStoRPacket;
	private String connectionTarget;
	private int ToRobotPort = 1110;
	private int FromRobotPort = 1150;
	
	private DatagramSocket ReadSocket;
	private DatagramSocket WriteSocket;
	
	private DatagramPacket ReadPacket;
	private DatagramPacket WritePacket;
	
	private byte[] ReadArray;
	private byte[] WriteArray;
	
	private RobotConnection()
	{
		RtoDSPacket = new RobotToDS();
		DStoRPacket = new DSToRobot();
	}
	
	public void SetTarget(String ip)
	{
		connectionTarget = ip;
	}
	
	public void Connect()
	{
		try
		{
			ReadSocket = new DatagramSocket(FromRobotPort);
			WriteSocket = new DatagramSocket();
			
			ReadArray = new byte[1024];
			WriteArray = new byte[1024];
			
			ReadPacket = new DatagramPacket(ReadArray, 1024);
			InetAddress dest = InetAddress.getByName(connectionTarget);
			WritePacket = new DatagramPacket(WriteArray, 1024, dest, ToRobotPort);
		}
		catch(Exception ex)
		{
		}
	}
	
	public void Disconnect()
	{
		ReadSocket.close();
		WriteSocket.close();
	}
	
	public void ReadPacket() throws IOException
	{
		ReadSocket.receive(ReadPacket);
	}
	
	public void WritePacket() throws IOException
	{
		WriteSocket.send(WritePacket);
	}
}
