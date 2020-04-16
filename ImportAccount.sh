#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ImportAllUserZimbra
# version: 1.0
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
#----------------------------------------------------------------------------------------------------------------


# GET ALL COS
# zmprov gc professional | grep zimbraId

#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# Variables fecha
DATE=$(date +"%Y%m%d")

# Variables Carpetas
FOLDER="/opt/zimbra/scripts"

# Variables Ficheros
LISTADO="ListAllAccount.csv"

# Otras variables
COS_NM1="professional"
COS_NM2="professional2"
COS_ID1="087bf9be-2c81-4f5f-bb8a-170b21714ca2"
COS_ID2="376daa10-d0fc-4aaa-87b1-7cb12ffe9c66"


cp -f  ListAllAccount.csv2 ListAllAccount.csv
#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------
# Modificar el cos del nombre al id
sed -i 's/'$COS_NM2'/'$COS_ID2'/'  $FOLDER/$LISTADO
sed -i 's/'$COS_NM1'/'$COS_ID1'/'  $FOLDER/$LISTADO

cat $LISTADO | while read LINEA; do
 #echo "  LINEA = $LINEA"
 
 CAMPO1=$(echo $LINEA | cut -d ";" -f 1)
 CAMPO2=$(echo $LINEA | cut -d ";" -f 2)
 CAMPO3=$(echo $LINEA | cut -d ";" -f 3)
 CAMPO4=$(echo $LINEA | cut -d ";" -f 4)
 CAMPO5=$(echo $LINEA | cut -d ";" -f 5)
 CAMPO6=$(echo $LINEA | cut -d ";" -f 6)
 CAMPO7=$(echo $LINEA | cut -d ";" -f 7) 
 CAMPO8=$(echo $LINEA | cut -d ";" -f 8)
		
 #echo "  - Referencia = $CAMPO1"
 #echo "  - Direccion de correo = $CAMPO2"
 #echo "  - Nombre Mostrado = $CAMPO3"
 #echo "  - Nombre = $CAMPO4"
 #echo "  - Apellido = $CAMPO5"
 #echo "  - UID = $CAMPO6"
 #echo "  - Password = $CAMPO7"
 #echo "  - COS = $CAMPO8"

 echo "zmprov ca $CAMPO2 $CAMPO7 displayName '"$CAMPO3"' givenName '"$CAMPO4"' sn '"$CAMPO5"' zimbraCOSid $CAMPO8"
 zmprov ca $CAMPO2 $CAMPO7 displayName "$CAMPO3" givenName "$CAMPO4" sn "$CAMPO5" zimbraCOSid $CAMPO8

done
