#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ReportZimbraAttack
# version: 1.0.0 (2020.05.22)
# autor: Jose Luis Romera
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                           Notas
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# Fecha/Tiempo
FECHA=$(date +"%Y-%m-%d")
TIEMPO=$(date +"%Y-%m-%d %H:%M:%S")
SECONDS=0

# Carpetas
FOLDER="/opt/ReportZimbraAttack"
FOLDER_HTML="/var/www/html/ReportAtack"

# Ficheros Temporales
# CSV
# Logs
# Varios  

#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------

rm -f $FOLDER/index.html && mkdir -p $FOLDER/hissrv

# Creamos la cabezera del index
cat $FOLDER/templante_html/header.tpl >> $FOLDER/index.html
sed -i "s/FECHA_REPORT/$FECHA/" $FOLDER/index.html

cat $FOLDER/listado.server | while read LINEA; do

    # Eliminamos temporales
    rm -f $FOLDER/tabla.tmp
    rm -f $FOLDER/list.tmp

    # Leemos la linea
    SERVER_ADDR=$(echo $LINEA | cut -d ";" -f 1)
    SERVER_NAME=$(echo $LINEA | cut -d ";" -f 2)
    
    # Sacamos el hostname del servidor
    ZMHOSTNAME=$(0</dev/null ssh root@$SERVER_ADDR "su - zimbra -c "'"zmhostname "'"")
    
    # Sacamos la informacion del servidor
    0</dev/null ssh root@$SERVER_ADDR "cat /var/log/zimbra.log | grep "'"authentication failed: authentication failure"'" \\
                                                                | sed -n "'"s/.*warning://p"'" \\
                                                                | awk "'"{print $1}"'" \\
                                                                | cut -d"'"["'" -f2 \\
                                                                | cut -d"'"]"'" -f1 \\
                                                                | sort \\
                                                                | uniq -c \\
                                                                | sort -nr \\
                                                                | head -5" >> $FOLDER/list.tmp

    # Quitamos tabulaciones // cambiamos el " " por ";"
    sed -i -e 's/^[ t]*//; s/[ t]*$//; /^$/d' $FOLDER/list.tmp
    sed -i 's/ /;/' $FOLDER/list.tmp

    # Cramos la cabecera de la tabla
    rm -rf $FOLDER/tableheader.tmp
    cat $FOLDER/templante_html/tableheader.tpl >> $FOLDER/tableheader.tmp
    sed -i "s/SERVIDOR_NOMBRE/$ZMHOSTNAME/" $FOLDER/tableheader.tmp
    sed -i "s/SERVIDOR_DIRECCION/$SERVER_ADDR/" $FOLDER/tableheader.tmp
    sed -i "s/SERVIDOR_NOMBRE/$ZMHOSTNAME/" $FOLDER/tableheader.tmp
    cat $FOLDER/tableheader.tmp >> $FOLDER/index.html
    
    # Creamos la fila con cada direccion atacante
    VAR="1"
    cat $FOLDER/list.tmp | while read LINEA; do
        rm -f $FOLDER/tablefilas.tpl.tmp
        cp $FOLDER/templante_html/tablefilas.tpl $FOLDER/tablefilas.tmp

        REPT=$(echo $LINEA | cut -d ";" -f 1)
        ADDR=$(echo $LINEA | cut -d ";" -f 2)

        # Sacamos la ubicacion de la ip
        REGION=`curl ipinfo.io/"$ADDR" 2>/dev/null | awk -F'"' '$2=="city"{printf("%s, ", $4)}$2=="region"{print $4}'`
        
        # Modifiamos las variables
        sed -i "s/FILA_POS/$VAR/" $FOLDER/tablefilas.tmp
        sed -i "s/FILA_REP/$REPT/" $FOLDER/tablefilas.tmp
        sed -i "s/FILA_ADD/$ADDR/" $FOLDER/tablefilas.tmp
        sed -i "s/FILA_GPS/$REGION/" $FOLDER/tablefilas.tmp

        # Añadimos la tabla al index
        cat $FOLDER/tablefilas.tmp >> $FOLDER/index.html

        # Creamos log historico
        echo "$TIEMPO;$VAR;$REPT;$ADDR;$REGION" >> $FOLDER/hissrv/$ZMHOSTNAME.txt

        VAR=$((VAR+1))
    done

    # Añadimos el final de la tabla
    echo "</div>" >> $FOLDER/index.html

    # Copiamos el fichero para el historico
    cp $FOLDER/hissrv/$ZMHOSTNAME.txt $FOLDER_HTML/hissrv/$ZMHOSTNAME.txt

done

# Añadimos el footer al html
cat $FOLDER/templante_html/footer.tpl >> $FOLDER/index.html
sed -i "s/FECHA_GENERACION/$TIEMPO/" $FOLDER/index.html

# Reemplazamos el index // historico
cp $FOLDER/index.html $FOLDER_HTML

# Elminamos temporales
rm -rf $FOLDER/*.tmp && rm -rf $FOLDER/*.tpl && rm -rf FOLDER/index.html

ELAPSED="Tiempo: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
echo $ELAPSED
