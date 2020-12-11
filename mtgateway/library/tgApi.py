import logging
import telegram
from telegram.error import NetworkError, Unauthorized
import time
from threading import Thread
import datetime
import pandas as pd
import re
import sys
#%% Telegram API
class tgApi(Thread):
    
    def __init__(
            self, 
            cmdQueue, 
            token, 
            botname, 
            authgroup, 
            itag, 
            otag,
            suicidable = False,
            ):
        Thread      .__init__(self)
        self.cmdQueue   = cmdQueue
        
        self.update_id  = None
        self.authgroup  = authgroup
        self.TOKEN      = token 
        self.botname    = botname
        self.bot        = None
        # i/o tag
        self.itag       = itag
        self.otag       = otag
        self.suicidable = suicidable
    
        logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        
        self.lmtFailsafe    = 10
        self.tsFailsafe     = time.time() + self.lmtFailsafe
        self.thID           = self.itag + '-' + str(int(self.tsFailsafe))
        
    def listen(self):
        """Echo the message the user sent."""
        # Request updates after the last update_id
        for update in self.bot.get_updates(offset = self.update_id, timeout=10):
            self.update_id = update.update_id + 1
            try:
                if update.message.chat.id == self.authgroup:
                    self.chat_id = update.message.chat.id
                    input_msg = update.message.text
                    try:                        
                        # entities exists and type is bot_command 
                        if input_msg.endswith(self.botname):                        
                            input_msg = input_msg[:-len(self.botname)]              
                        if update.message.entities and update.message.entities[0].type == 'bot_command':
                            input_msg = input_msg[1:]                               
                        input_msg = re.split("[, \-!?:_]+", input_msg)
                            
                        self.cmdQueue[self.otag].put(input_msg)
                        self.cmdQueue[self.otag].join()  # blocks until consumer calls task_done()
                    except Exception as e:
                        print (
                                self.itag, 
                                sys._getframe().f_code.co_name, 
                                'invalid command: ', 
                                e,
                                )
            except Exception as e:
                print (
                        self.itag, 
                        sys._getframe().f_code.co_name, 
                        e,
                        )
                time.sleep(1)
                
    
    def cycle(self):
        try:
            # Telegram Bot Authorization Token
            if not self.bot:
                self.bot = telegram.Bot(self.TOKEN)
                try:
                    self.update_id = self.bot.get_updates()[0].update_id
                except IndexError:
                    self.update_id = None
            else:
                self.listen()
        except NetworkError:
            time.sleep(1)
        except Unauthorized:
            # The user has removed or blocked the bot.
            self.update_id += 1
        except Exception as e:
            print (
                    self.itag, 
                    sys._getframe().f_code.co_name, 
                    e,
                    )
            time.sleep(1)
        
    def run(self):
        """
        Run is the main-function in the new thread. Here we overwrite run
        inherited from threading.Thread.
        """
        self.status = True
        while self.status:
            if (    # can be suicided
                    self.suicidable
                    # Failsafe Shutdown
                and time.time() > self.tsFailsafe + self.lmtFailsafe                
                    ):
                print(self.thID, 'BREAK!')
                break              
            if self.cmdQueue[self.itag].empty():
                self.cycle()
                time.sleep(1)                           # optional heartbeat
                
            else:
                self.prompt()
                self.cmdQueue[self.itag].task_done()  # unblocks prompter
        raise SystemExit
                
    def stop(self):
        self.status = False
        Thread.join(self, None)
        
    def prompt(self):
        try:
            while not self.cmdQueue[self.itag].empty():
                cmds = self.cmdQueue[self.itag].get()
                if (
                        '.png' in cmds
                        ):
                    self.bot.send_photo(chat_id = self.authgroup, photo=open(cmds, 'rb'), timeout=100)
                else:
                    self.bot.send_message(chat_id = self.authgroup, text = cmds)
                
        except Exception as e:
            print('Command `{cmds}` is unknown: ', e)
            
    # Report Params
    def set(self, name, val):
        if name == 'accounts':
            self.accounts   = val
        elif name == 'tsFailsafe': 
            self.tsFailsafe = val
        return None