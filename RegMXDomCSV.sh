#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: RegMXDomCSV
# version: 1.0a
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
#----------------------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# Listados
LISTASERV="/tmp/ListadoServer.txt"

LISTDOM="/tmp/ListadoDigDominios.csv"
LISTDOMTMP="/tmp/ListadoDigDominios.tmp"
LISTDIGTMP="/tmp/ListadoDigMX.tmp"

# Logs
LOGEJECUCION="/tmp/DigDominios.log"



#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------

# Limpiamos ficheros ficheros/logs
cat /dev/null > $LISTDOM
cat /dev/null > $LISTDOMTMP
cat /dev/null > $LOGEJECUCION
cat /dev/null > $LISTDIGTMP
echo "Eliminados los ficheros/logs" >> $LOGEJECUCION

echo "Servidor;Hostname;Domain;MX" >> $LISTDOM

cat $LISTASERV | while read LINE_A1; do
 SERVIDORIP=$(echo $LINE_A1 | cut -d ";" -f 1)
 SERVIDORPORT=$(echo $LINE_A1 | cut -d ";" -f 2)
 
 # Comprobamos que ldap esta corriendo en la maquina
 LDAPEXEV=$(ssh root@$SERVIDORIP -p $SERVIDORPORT "su - zimbra -c "'"zmcontrol status | grep ldap | cut -c26-32  "'"")
 echo "Comprobamos si $SERVIDORIP tiene ldap en ejecucion" >> $LOGEJECUCION
 
 if [ $LDAPEXEV == "Running" ]
 then
  # Sacamos el fqdn
  HOSTNAME=$(ssh root@$SERVIDORIP -p $SERVIDORPORT "hostname -A")
  echo "Start $HOSTNAME" >> $LOGEJECUCION
  
  # Sacamos los dominios configurados en el servidor
  DOMAINS=$(ssh root@$SERVIDORIP -p $SERVIDORPORT "su - zimbra -c "'"zmprov gad"'"")
  echo "Sacados los dominios de $HOSTNAME" >> $LOGEJECUCION

  for DOMAIN in ${DOMAINS}; do
   cat /dev/null > $LISTDIGTMP
   dig $DOMAIN MX +short >> $LISTDIGTMP

   cat $LISTDIGTMP | while read REGMXDOM; do
    echo "$SERVIDORIP;$HOSTNAME;$DOMAIN;$REGMXDOM" >> $LISTDOM
   done    
  done

  # Limpiamos un " ,"
  sed -i 's/ ;/;/' $LISTDOM

 else
  echo "El Servidor $SERVIDORIP no tiene ldap corriendo" >> $LOGEJECUCION
 fi
 
done
