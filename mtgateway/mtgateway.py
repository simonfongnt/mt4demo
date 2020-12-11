
import os, sys
clientDir = os.path.abspath(sys.argv[0] + "/..")
os.chdir(getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__))))
from library.tgApi import tgApi

import time
import logging
from queue import Queue
from threading import Thread
import subprocess
import datetime
import json
import pandas as pd
import datetime
from dateutil import tz
import signal

import socket
import selectors
import types

from multiprocessing import Process, Manager, freeze_support
        
def main(argv):
    
    login       = json.load(
                        open(
                            os.path.join(
                                clientDir,
                                'config',
                                'login.json'
                                ),
                            )
                        )
    # initialize thread channels
    thcmds = {}
    thcmds['tgApi']  = Queue()
    thcmds['bot']    = Queue()
    ths = {}
    ths['tgApi'] = tgApi(
            cmdQueue = thcmds, 
            token       = login['telegram']['token'],
            botname     = login['telegram']['botname'], 
            authgroup   = login['telegram']['authgroup'],
            itag        = "tgApi",
            otag        = "bot",
            )
    print(
        'telegram:',
        login['telegram']['token'],
        login['telegram']['botname'], 
        login['telegram']['authgroup'], 
    )
    # prepare threadings
    # initialize threadings
    for key, th in ths.items():     
        th.daemon = True
        th.start()
    # initialize process channels
    manager             = Manager()
    smpCmds             = {}
    rmpCmds             = {}
    impReqs             = {}
    mps                 = {}
    is_on               = {}
    is_auto             = {}
    
    thcmds['tgApi'].put('client starts')
    pkey = 'bot'

    # socket
    HOST = login['server']['host']
    PORT = login['server']['port']
    print(
        'MT Communication @',
        HOST,
        PORT,
    )
    
    sel = selectors.DefaultSelector()
    lsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    lsock.bind((HOST, PORT))
    lsock.listen()
    print('listening on', (HOST, PORT))
    lsock.setblocking(False)
    sel.register(lsock, selectors.EVENT_READ, data=None)
    while True:
        events = sel.select(timeout=None)
        for key, mask in events:
            if key.data is None:
                # accept_wrapper(key.fileobj)
                sock = key.fileobj
                conn, addr = sock.accept()  # Should be ready to read
                print('accepted connection from', addr)
                conn.setblocking(False)
                data = types.SimpleNamespace(addr=addr, inb=b'', outb=b'')
                events = selectors.EVENT_READ | selectors.EVENT_WRITE
                sel.register(conn, events, data=data)
            else:
                # service_connection(key, mask)
                sock = key.fileobj
                data = key.data
                if mask & selectors.EVENT_READ:
                    recv_data = sock.recv(1024)  # Should be ready to read
                    if recv_data:
                        data.outb += recv_data
                    else:
                        print('closing connection to', data.addr)
                        sel.unregister(sock)
                        sock.close()
                if mask & selectors.EVENT_WRITE:
                    if data.outb:
                        try:
                            thcmds['tgApi'].put(data.outb.decode())
                        except Exception as e:
                            print(e)
                        print('echoing', repr(data.outb), 'to', data.addr)
                        sent = sock.send(data.outb)  # Should be ready to write
                        data.outb = data.outb[sent:]

#%%
if __name__ == '__main__':
    # Pyinstaller fix
    # https://github.com/pyinstaller/pyinstaller/wiki/Recipe-Multiprocessing
    freeze_support()
    # print('run client.py', clientDir)
    print('client.py', 'is running.')
    main(sys.argv)