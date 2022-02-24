#!/usr/bin/env python3
  
import json
import socket
import datetime

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
        print(row)