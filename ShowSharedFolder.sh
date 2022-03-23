#!/bin/bash
NUM_RANDOM=$RANDOM

if  [[ $1 = "-d" ]]; then
    echo "DOMINIO"


elif [[ $1 = "-u" ]]; then
    echo "Exportamos a un fichero las carpetas del usuario"
    zmmailbox -z -m $2 gaf | egrep -v ':|Count|----------' | cut -c 43- > /tmp/folders$NUM_RANDOM.tmp

    cat /tmp/folders$NUM_RANDOM.tmp | while read FOLDER; do
        zmmailbox -z -m  $2 gfg "$FOLDER" | egrep -v "Permissions" | egrep -v "-" > /tmp/Shared$NUM_RANDOM.tmp

        cat /tmp/Shared$NUM_RANDOM.tmp | while read SHARED; do
            echo Grants for $2: $FOLDER: $SHARED
        done

        echo
        
    done

    rm -rf /tmp/Shared$NUM_RANDOM.tmp /tmp/folders$NUM_RANDOM.tmp


else
    echo ""
    echo "Usage: ./SharedFolder.sh [options] [DOMAIN / USER]"
    echo ""
    echo "Options:"
    echo "  -d                  Crear usuario nuevo"
    echo "  -u                  Cambiar password de usuario"
    echo ""
fi
