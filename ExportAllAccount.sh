#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ExportAllUserZimbra
# version: 1.0
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# Variables fecha
DATE=$(date +"%Y%m%d")

# Variables Carpetas
PATHTMP="/opt/zimbra/scripts"

# Variables Ficheros
LISTTMP="ListUsers.tmp"
LISTADO="ListAccount.csv"

# Variables Comandos
ZMPROV="/opt/zimbra/bin/zmprov"

# Otros
COS=$(echo "displayName givenName sn uid userPassword")
#COS=$(echo "givenName sn uid userPassword")


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------
# Conseguimos todas las cuentas
CUENTAS=`zmprov -l gaa | egrep -v 'admin|wiki|galsync|spam|ham|virus'`;

# Limpiamos listado
cat /dev/null > $PATHTMP/$LISTADO

# Agregamos los campos
echo "email;displayName;givenName;sn;uid;userPassword" >> $PATHTMP/$LISTADO

# loop for each CUENTA
for CUENTA in ${CUENTAS}; do
  RESULTADO=`$ZMPROV -l ga ${CUENTA} $COS | grep -v "#" | awk '{print $0";"}' | sed 's/givenName: //'  | sed 's/sn: //'   | sed 's/displayName: //'   | sed 's/uid: //'   | sed 's/userPassword: //'  |tr -d '\n' | head -c-2`;
  echo "$CUENTA;$RESULTADO" >> $PATHTMP/$LISTADO
done

