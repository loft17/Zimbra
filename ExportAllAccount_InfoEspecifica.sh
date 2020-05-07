#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ExportAllUserZimbraAranSalut
# version: 1.6
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# Variables Carpetas
FOLDER="/opt/zimbra/scripts/Resports"
# Variables Ficheros
LISTADO="ListAccount.csv"
# Otros
COS=$(echo "displayName zimbraAccountStatus")
# Time
DATE=$(date +"%Y%m%d")
# Logs


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------

# Limpiamos listado
cat /dev/null > $FOLDER/$LISTADO-$DATE

# Agregamos los campos
echo "email;displayName;Status;Description;COSid;Created;LastLogon;Size;Alias" >> $FOLDER/$LISTADO-$DATE

# Conseguimos todas las cuentas
CUENTAS=`zmprov -l gaa | egrep -v 'admin|wiki|galsync|spam|ham|virus'`;

# loop for each CUENTA
for EMAIL in ${CUENTAS}; do
    SECONDS=0
    RESULTADO_ALIAS=""

    # Sacamos la informacion de la cuenta
    RESULTADO=`zmprov -l ga $EMAIL $COS | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-1`
    DESCRIPTION=`zmprov -l ga $EMAIL description | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-1`
    COSID=`zmprov -l ga $EMAIL zimbraCOSId | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-1`

    # Sacamos la fecha de creacion de la cuenta.
    CREATED=`zmprov -l ga $EMAIL zimbraCreateTimestamp | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-8`
    CREATEDDATE=$(echo $CREATED | head -c-5) && CREATEDDATE=$(date -d "$CREATEDDATE" +"%Y/%m/%d")
    CREATEDTIME=$(echo $CREATED | cut --complement -c 1-8) && CREATEDTIME=$(date -d "$CREATEDTIME" +"%R")

    # Sacamos el ultimo login
    LASTLOGON=`zmprov -l ga $EMAIL zimbraLastLogonTimestamp | grep -v "#" | awk '!/^$/' | awk -F": " '{print $2";"}' | tr -d '\n' | head -c-8`
    LASTLOGONDATE=$(echo $LASTLOGON | head -c-5) && LASTLOGONDATE=$(date -d "$LASTLOGONDATE" +"%Y/%m/%d")
    LASTLOGONTIME=$(echo $LASTLOGON | cut --complement -c 1-8) && LASTLOGONTIME=$(date -d "$LASTLOGONTIME" +"%R")

    # Sacamos el tamaño del buzon
    MB_SIZE=`zmmailbox -z -m ${EMAIL} gms | tr . ,`

    # Averiguamos si tiene alias la cuenta
    RESULTADO_ALIAS=`zmprov -l ga $EMAIL zimbraMailAlias | grep -v "#" | grep .  | awk -F: '{print $1}'`

    # Agregamos alias si es necesario
    if [[ $RESULTADO_ALIAS == "zimbraMailAlias" ]]
        then
            MEMALIAS=`zmprov -l ga $EMAIL zimbraMailAlias | grep -v "#" | awk -F "zimbraMailAlias: " '{print $2}' | grep . | awk 'ORS=";"' | head -c-1`
            echo "$EMAIL;$RESULTADO;$DESCRIPTION;$COSID;$CREATEDDATE $CREATEDTIME;$LASTLOGONDATE $LASTLOGONTIME;$MB_SIZE;$MEMALIAS" >> $FOLDER/$LISTADO-$DATE
            ELAPSED="Tiempo: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
        else
            echo "$EMAIL;$RESULTADO;$DESCRIPTION;$COSID;$CREATEDDATE $CREATEDTIME;$LASTLOGONDATE $LASTLOGONTIME;$MB_SIZE" >> $FOLDER/$LISTADO-$DATE
            ELAPSED="Tiempo: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
    fi
    echo $ELAPSED
done
echo done
