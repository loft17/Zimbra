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

;;087bf9be-2c81-4f5f-bb8a-170b21714ca2;20200417063252.545Z;;378,45 MB

# Agregamos los campos
echo "email;displayName;Status;COSId;Created;description;Size" >> $FOLDER/$LISTADO

# Conseguimos todas las cuentas
CUENTAS=`zmprov -l gaa | egrep -v 'admin|wiki|galsync|spam|ham|virus'`;

# loop for each CUENTA
for EMAIL in ${CUENTAS}; do
  # Sacamos la informacion de la cuenta
  RESULTADO=`zmprov -l ga $EMAIL $COS | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-1`
  DESCRIPTION=`zmprov -l ga $EMAIL description | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-1`
  # Sacamos el tamaño del buzon
  MB_SIZE=`zmmailbox -z -m ${EMAIL} gms | tr . ,`
  
  # Creamos el fichero
  echo "$EMAIL;$RESULTADO;$DESCRIPTION;$MB_SIZE" >> $FOLDER/$LISTADO
done

echo done
