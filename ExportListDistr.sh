#!/bin/bash

#----------------------------------------------------------------------------------------------------------------
#                                                                                                            Info
#----------------------------------------------------------------------------------------------------------------
# name: ExportListDistr
# version: 1.2
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
COS=$(echo "displayName zimbraCreateTimestamp zimbraId zimbraMailStatus")

FOLDER_EXPORT="/tmp/Zimbra"
LIST_EXPORT="ExportListDistr.csv"



#----------------------------------------------------------------------------------------------------------------
#                                                                                                       Funciones
#----------------------------------------------------------------------------------------------------------------

# Vaciamos los ficheros:
cat /dev/null > $FOLDER_EXPORT/$LIST_EXPORT

# Construimos la esctructura del csv
echo "email;displayName;zimbraCreateTimestamp;zimbraId;zimbraMailStatus;members" >> $FOLDER_EXPORT/$LIST_EXPORT

for EMAIL in `zmprov gadl` ; do
 RESULTADO=`zmprov gdl $EMAIL  $COS | grep -v "#" | awk '{print $2}' | awk '!/^$/' | awk '{print $1";"}' |tr -d '\n' | head -c-2`
 ALIASMEM=`zmprov gdl $EMAIL | awk -F "zimbraMailForwardingAddress: " '{print $2}' | grep . | awk 'ORS=";"'`
 echo "$EMAIL;$RESULTADO;$ALIASMEM" >> $FOLDER_EXPORT/$LIST_EXPORT
done
