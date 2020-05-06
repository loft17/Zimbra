#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ExportAllUserZimbraAranSalut
# version: 1.5
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# Variables Carpetas
FOLDER="/tmp/Zimbra"
# Variables Ficheros
LISTADO="ListAccount.csv"
# Otros
COS=$(echo "displayName zimbraAccountStatus zimbraLastLogonTimestamp zimbraCreateTimestamp zimbraCOSId")


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------
# Limpiamos listado
cat /dev/null > $FOLDER/$LISTADO

# Agregamos los campos
echo "email;displayName;Status;COSId;Created;description;Size;Alias" >> $FOLDER/$LISTADO

# Conseguimos todas las cuentas
CUENTAS=`zmprov -l gaa | egrep -v 'admin|wiki|galsync|spam|ham|virus'`;

# loop for each CUENTA
for EMAIL in ${CUENTAS}; do
  RESULTADO_ALIAS=""
  # Sacamos la informacion de la cuenta
  RESULTADO=`zmprov -l ga $EMAIL $COS | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-1`
  DESCRIPTION=`zmprov -l ga $EMAIL description | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-1`
  # Sacamos el tamaño del buzon
  MB_SIZE=`zmmailbox -z -m ${EMAIL} gms | tr . ,`
  # Averiguamos si tiene alias la cuenta
  RESULTADO_ALIAS=`zmprov -l ga $EMAIL zimbraMailAlias | grep -v "#" | grep .  | awk -F: '{print $1}'`
  # Agregamos alias si es necesario
  if [[ $RESULTADO_ALIAS == "zimbraMailAlias" ]]
  then
    MEMALIAS=`zmprov -l ga $EMAIL zimbraMailAlias | grep -v "#" | awk -F "zimbraMailAlias: " '{print $2}' | grep . | awk 'ORS=";"' | head -c-1`
        echo "$EMAIL;$RESULTADO;$DESCRIPTION;$MB_SIZE;$MEMALIAS" >> $FOLDER/$LISTADO
  else
    echo "$EMAIL;$RESULTADO;$DESCRIPTION;$MB_SIZE" >> $FOLDER/$LISTADO
  fi
done

echo done
