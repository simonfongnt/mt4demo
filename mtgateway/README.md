# About
An app for win OS as gateway passing message from mt4 to telegram

# Prerequisite
* telegram bot and group
* socket.mph
* python 3.7

```pip install pyinstaller```

* modify config/login.json

```
"server":{
  "host": "",     <-- localhost
  "port": 12345   <-- same as defined as socket.mph
},
"telegram":{
  "token": "99999999:asl;kdfjk;lsadjf;lkashdflajkdf",  <-- obtain from BotFather
  "botname": "@THEBOTNAME",                            <-- the Botname
  "authgroup": -84235170148957                         <-- telegram group number (replaced g to -)           
}
```


# Python
run with python

```
python mtgateway.py
```

# Windows
in order to run it as executable, building with pyinstaller in Windows is necessary.
## Build (Pyinstaller)
make sure to update this path to the project folder:

```
pathex=['C:\\path\\to\\mtgateway'],
```
build the executable:

```pyinstaller mtgateway.spec```

dist/ will then be created consisted of executable mtgateway.py
in order to use the executable, please copy config/ into dist/, e.g.

```
dist
|-- config
|   |--login.json
|--mtgateway.exe
```

with updated login.json, mtgateway.exe can be run with this file structure.
