#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ExportMailboxAllAccountIncremental
# version: 1.0
# autor: Jose Luis Romera
#----------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# // CARPETAS
FOLDEREXPORT="XXXXXX"
FOLDERLIST="/opt/zimbra/scripts"

# // LISTADO
LISTADO="ListAccount.csv"

# // FECHAS
FECHA_ACTUAL=$(date +"%m/%d/%Y")
FECHA_AFTER=$(date +"%m/%d/%Y" --date='-7 day')
SEGUNDOS=$(date +"%T")
DATELOG=$(date +"%Y%m%d")

#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------

#mkdir -p $FOLDEREXPORT/$FECHA
rm -f $FOLDERLIST/IncrementalBackul_$DATELOG.log
touch $FOLDERLIST/IncrementalBackul_$DATELOG.log

rm -rf $FOLDEREXPORT/$DATELOG
mkdir -p $FOLDEREXPORT/$DATELOG

for EMAIL in `cat $FOLDERLIST/$LISTADO | cut -d ";" -f 1`; do
 echo "$SEGUNDOS - Start  - $EMAIL" >> $FOLDERLIST/IncrementalBackul_$DATELOG.log
 zmmailbox -z -m $EMAIL getRestURL -u https://localhost '//?fmt=tgz&query=after:'$FECHA_AFTER'' > $FOLDEREXPORT/$DATELOG/$EMAIL.tgz
 echo "$SEGUNDOS - Finish - $EMAIL" >> $FOLDERLIST/IncrementalBackul_$DATELOG.log
done
