#!/bin/bash

# Definimos las variables de configuración
KEY_ID="254F9170B966D193D6BAD300D5CEF8BF9BE6ED79"
ZIMBRA_KEYRING="/etc/apt/trusted.gpg.d/zimbra.gpg"
ZIMBRA_PUBLIC_KEY="9BE6ED79"
TRUSTED_GPG_DIR="/etc/apt/trusted.gpg.d"

# Función para mostrar la ayuda
show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -n            Normal execution (verify and import key if not present)"
  echo "  -f            Force re-import of the Zimbra GPG key (removes old keys first)"
  echo "  -h            Show this help message"
}

# Comprobamos si se pasó el parámetro -f (forzar), -n (normal), o -h (help)
FORCE_REIMPORT=false
NORMAL_EXECUTION=false

while getopts "fnh" opt; do
  case $opt in
    f)
      FORCE_REIMPORT=true
      ;;
    n)
      NORMAL_EXECUTION=true
      ;;
    h)
      show_help
      exit 0
      ;;
    *)
      show_help
      exit 1
      ;;
  esac
done

# Si no se pasa ningún parámetro, mostramos los parámetros disponibles
if [ $OPTIND -eq 1 ]; then
  show_help
  exit 1
fi

# Función para eliminar la clave de apt-key
remove_key() {
  echo "Eliminando la clave GPG con ID ${KEY_ID}..."
  apt-key del "$KEY_ID"
}

# Función para eliminar claves de Zimbra en el directorio de claves de apt
remove_zimbra_keys_from_directory() {
  echo "Buscando y eliminando archivos relacionados con Zimbra en ${TRUSTED_GPG_DIR}..."
  rm -f "${TRUSTED_GPG_DIR}"/*zimbra*
}

# Función para realizar la importación de la clave usando apt-key
import_zimbra_key() {
  echo "Importando la clave GPG de Zimbra desde el servidor de claves usando apt-key..."
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$ZIMBRA_PUBLIC_KEY"
  
  # Verificamos si la importación fue exitosa
  if [ $? -eq 0 ]; then
    echo "Clave GPG de Zimbra importada correctamente."
    
    # Ejecutamos apt update para actualizar los repositorios
    echo "Ejecutando apt update para actualizar los repositorios..."
    sudo apt update
    
    echo "Proceso completado con éxito. Los repositorios se han actualizado."
  else
    echo "Error al importar la clave GPG de Zimbra. Por favor, verifica el servidor de claves."
    exit 1
  fi
}

# Verificamos si la clave existe en el archivo de claves de Zimbra
echo "Verificando si la clave ${KEY_ID} está presente en el sistema..."

# Listamos las claves en el archivo de claves del sistema y buscamos la clave
apt-key list | grep -w "$KEY_ID"

# Si la clave no se encuentra o si el parámetro -f fue pasado, forzamos la eliminación e importación
if [ $? -ne 0 ] || [ "$FORCE_REIMPORT" = true ]; then
  if [ "$FORCE_REIMPORT" = true ]; then
    # Eliminar la clave si el parámetro -f fue pasado
    remove_key

    # Eliminar claves relacionadas con Zimbra en el directorio de claves de apt
    remove_zimbra_keys_from_directory
  fi

  # Importamos la clave de Zimbra
  import_zimbra_key
elif [ "$NORMAL_EXECUTION" = true ]; then
  echo "La clave ya está presente. No es necesario importar nuevamente."
fi

exit 0
