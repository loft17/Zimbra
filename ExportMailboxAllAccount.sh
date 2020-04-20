#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ExportMailboxAllAccount
# version: 1.0
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
#----------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

FOLDEREXPORT="/opt/zimbra/backup/migracion/"
FOLDERLIST="/opt/zimbra/scripts"
LISTADO="ListadoCuentas.txt"


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------
#!/bin/bash
for EMAIL in `cat $FOLDERLIST/$LISTADO | cut -d ";" -f 1`; do
 echo $EMAIL
 #zmmailbox -z -m $EMAIL getRestURL -u https://localhost "//?fmt=tgz" > $FOLDEREXPORT/$EMAIL.tgz
 zmmailbox -z -m $EMAIL getRestURL -u https://localhost '//?fmt=tgz&query=before:4/19/2020' > $FOLDEREXPORT/$EMAIL.tgz

 done
