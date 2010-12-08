===========
dict-notify
===========
:Author: 
    Pascal Schnurr
:Version:
    Draft


Overview
========
dict-notify is a dictd client (written in Vala) which looks up selected words
over a local dictd server and shows short results ( < 100 chars )
over the notification system (libnotify). 


Installation
============

for compilation vala, gtk and libnotify developement are needed to be installed.
also for running dict-notify dictd and some notification system needs to be installed and running.
then just compile it with
::
    make

and install with
::
    make install
    
(might require sudo if youre no superuser) 

then it can be run with the command
::
    dict-notify

remember that dictd needs to be up and running with some dictionarys
installed or else it might just crash.
