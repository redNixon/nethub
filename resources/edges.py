#!/usr/bin/env python3
  
import json
import socket
import datetime
import os.path

# Load macaddr registration.
# Content of devices.json should be like:
# {"MA:CA:DD:RE:SS:00":"Description"}
devices = {}
if os.path.isfile('devices.json'):
    with open('devices.json', 'r') as file:
        devices = json.load(file)

# Create and connect local UDP socket to supernode management.
local_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
local_socket.connect(('127.0.0.1', 5645))

# Send edges command.
local_socket.sendall(b"r 1 edges")

# Parse all response rows until end.
row = {'_type':''}
while row['_type']!='end':

    # Receive a bytes row, convert it to string and remove the newline character.
    raw = local_socket.recv(4096).decode('utf-8').replace('\n','')

    # Convert the row to dictionary.
    row = json.loads(raw)

    # If the row isn't a begin or end row, show the row.
    if row['_type'] not in ['begin','end']:

        # Convert the unix timestamp to general time.
        date_time = datetime.datetime.fromtimestamp(row['last_seen'])
        row['last_seen'] = date_time.strftime('%Y-%m-%d %H:%M:%S')

        # Show the entire row.
        print("-"*20)
        print("user:", row["desc"])
        print("community:", row["community"])
        # Check if device is regisred in devices.json
        if row["macaddr"] in devices:
            print("device:", devices[row["macaddr"]])
        else:
            print("device:", "unknown")
        print("from:", row["sockaddr"])
        print("mac:", row["macaddr"])
        print("to:", row["ip4addr"])
        print("seen:", row["last_seen"])