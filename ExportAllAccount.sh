#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ExportAllUserZimbra
# version: 1.1a
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
LISTADO="ListAccount.csv"

# Variables Comandos
ZMPROV="/opt/zimbra/bin/zmprov"
ZMMAILBOX="/opt/zimbra/bin/zmmailbox"

# Otros
COS=$(echo "displayName givenName sn uid")

#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------
# Conseguimos todas las cuentas
CUENTAS=`zmprov -l gaa | egrep -v 'admin|wiki|galsync|spam|ham|virus'`;

# Limpiamos listado
cat /dev/null > $PATHTMP/$LISTADO

# Agregamos los campos
echo "email;displayName;givenName;sn;uid;espacio" >> $PATHTMP/$LISTADO

# loop for each CUENTA
for CUENTA in ${CUENTAS}; do
  RESULTADO=`$ZMPROV -l ga ${CUENTA} $COS | grep -v "#" | awk '{print $0";"}' | sed 's/givenName: //'  | sed 's/sn: //'   | sed 's/displayName: //'   | sed 's/uid: //'  |tr -d '\n' | head -c-2`;
  MB_SIZE=`$ZMMAILBOX -z -m ${CUENTA} gms`;
  MB_SIZE=`echo ${MB_SIZE} | tr . ,`;
  echo "$CUENTA;$RESULTADO;$MB_SIZE" >> $PATHTMP/$LISTADO
done

sed -i 's/KB/;1000/'  $PATHTMP/$LISTADO
sed -i 's/MB/;1000000/'  $PATHTMP/$LISTADO
sed -i 's/GB/;1000000000/'  $PATHTMP/$LISTADO
sed -i 's/B/;1/'  $PATHTMP/$LISTADO
