#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ExportAllResources
# version: 1.0
# autor: joseRomera <web@joseromera.net>
# web: http://www.joseromera.net
# Copyright (C) 2020
#----------------------------------------------------------------------------------------------------------------
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#----------------------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Variables
#----------------------------------------------------------------------------------------------------------------

# Carpetas
FOLDER="/tmp/Zimbra"
# Ficheros
FILETMP="ListRecursos.tmp"
FILELST="ListRecursos.csv"
# Zimbra
COS=$(echo "displayName zimbraAccountStatus description")



#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------

# Eliminamos los ficheros
rm -f $FOLDER/$FILETMP
rm -f $FOLDER/$FILELST

# Exportamos la informacion
zmprov gacr >> $FOLDER/$FILETMP

# Generamos la estructura del fichero
echo "email;description;displayName;zimbraAccountStatus" >> $FOLDER/$FILETMP

cat $FOLDER/$FILETMP | while read EMAIL; do
    RESULTADO=` zmprov gcr $EMAIL $COS | grep -v "#" | awk '!/^$/' | awk '{print $2";"}' |tr -d '\n' `;
    echo "$EMAIL;$RESULTADO" >> $FOLDER/$FILELST
done
