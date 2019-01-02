#!/bin/bash

#set -x

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

FICH_TEMP=/tmp/`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 18`
THREADS=8

while test -n "$1"; do

   case "$1" in

        -h|--help)
            echo -e "Script para realizar Fusing de una URL utilizando BING"
            echo -e "Uso del Script:\n Para el correcto funcionamiento del script tiene que facilitar los siguientes valores:\n\n\tURL\n\tDiccionario\n"
            echo -e "\t-u | --url ==> URL de la que se quiere realizar la busqueda"
            echo -e "\t-d | --diccionario ==> Ruta del diccionario que deseas utilizar para la busqueda"
            echo -e "\t-e | --extensions ==> Extensiones que se desan buscar separados por coma.(-e jsp,html,asp)"
            echo -e "\t-O | --output: ==> (Opcional) Ruta donde deseas gusrdar el fichero final. Por defecto el fichero se guardata con el siguiente nombre busqueda_[fecha-hora].txt."
            echo -e "\t-T | --threads: ==> (Opcional) Cantidad de hilos simultaneos de consulta (Por defecto 8)\n\n"
            exit ${STATE_CRITICAL}
            ;;
        -u|--url)
            URL=$2
            shift
            ;;
        -d|--diccionario)
            DICC=$2
            shift
            ;;
        -e|--extensions)
            EXTENSIONS=$2
            shift
            ;;
        -O|--output)
            FICHERO=$2
            shift
            ;;
        -T|--threads)
            THREADS=$2
            shift
            ;;
        *)
	    	echo -e "Script para realizar Fusing de una URL utilizando BING"
            echo -e "Uso del Script:\n Para el correcto funcionamiento del script tiene que facilitar los siguientes valores:\n\n\tURL\n\tDiccionario\n"
            echo -e "\t-u | --url ==> URL de la que se quiere realizar la busqueda"
            echo -e "\t-d | --diccionario ==> Ruta del diccionario que deseas utilizar para la busqueda"
            echo -e "\t-e | --extensions ==> Extensiones que se desan buscar separados por coma.(-e jsp,html,asp)"
            echo -e "\t-O | --output: ==> (Opcional) Ruta donde deseas gusrdar el fichero final. Por defecto el fichero se guardara con el siguiente nombre busqueda_[fecha-hora].txt."
            echo -e "\t-T | --threads: ==> (Opcional) Cantidad de hilos simultaneos de consulta (Por defecto 8)\n\n"
            exit ${STATE_CRITICAL}
            ;;

   esac

   shift

done

if [ -z ${FICHERO} ]; then
 	FICHERO=busqueda_`date -d now +"%Y%m%d-%T"`.txt
 else
 	FICHERO=${URL}_`date -d now +"%Y%m%d-%T"`.txt
 fi 

if [ -z ${DICC} ] && [ -z ${URL} ]; then
	echo -e "Es necesario facilitar un diccionario y URL para la busqueda:\n"
	echo -e "Uso del Script:\n Para el correcto funcionamiento del script tiene que facilitar los siguientes valores:\n\n\tURL\n\tDiccionario\n"
    echo -e "\t-u | --url ==> URL de la que se quiere realizar la busqueda"
    echo -e "\t-d | --diccionario ==> Ruta del diccionario que deseas utilizar para la busqueda"
    echo -e "\t-e | --extensions ==> Extensiones que se desan buscar separados por coma.(-e jsp,html,asp)"
    echo -e "\t-O | --output: ==> (Opcional) Ruta donde deseas gusrdar el fichero final. Por defecto el fichero se guardata con el siguiente nombre busqueda_[fecha-hora].txt."
    echo -e "\t-T | --threads: ==> (Opcional) Cantidad de hilos simultaneos de consulta (Por defecto 8)\n\n"
    exit ${STATE_CRITICAL}

elif [ ! -z ${DICC} ] && [ ! -z ${EXTENSIONS} ]; then
	echo -e "No se pueden usar los parametros -d y -e de manera simultanea:\n"
	echo -e "Uso del Script:\n Para el correcto funcionamiento del script tiene que facilitar los siguientes valores:\n\n\tURL\n\tDiccionario\n"
    echo -e "\t-u | --url ==> URL de la que se quiere realizar la busqueda"
    echo -e "\t-d | --diccionario ==> Ruta del diccionario que deseas utilizar para la busqueda"
    echo -e "\t-e | --extensions ==> Extensiones que se desan buscar separados por coma.(-e jsp,html,asp)"
    echo -e "\t-O | --output: ==> (Opcional) Ruta donde deseas gusrdar el fichero final. Por defecto el fichero se guardata con el siguiente nombre busqueda_[fecha-hora].txt."
    echo -e "\t-T | --threads: ==> (Opcional) Cantidad de hilos simultaneos de consulta (Por defecto 8)\n\n"
    exit ${STATE_CRITICAL}

elif [ -z ${EXTENSIONS} ] && [ ! -z ${DICC} ] ; then
	echo -e "`date -d now +"%T"` -- Empezamos el Fuzzing (DOMAIN) via Bing...\n"
	cat ${DICC} | xargs -n1 -P${THREADS} bash -c 'i=$0; url="https://www.bing.com/search?q=domain%3a'${URL}'%20${i}&first=1"; echo -e "`date -d now +"%T"` -- Buscando con la palabra ${i}..." ; curl -s $url | grep -Po "(?<=<a href=\").*?(?=\" h=)" | grep -Po "https?.*" | grep ${URL}' >> ${FICH_TEMP}
	echo -e "Proceso Finalizado el resultado es el siguiente:\n"
	cat ${FICH_TEMP} | sort | uniq | tee -a ${FICHERO}
	echo -e "Tambien puedes encontar el resulto completo en ${FICHERO}\n"
	rm -fr ${FICH_TEMP}
	exit ${STATE_OK}

elif [ -z ${DICC} ] && [ ! -z ${EXTENSIONS} ]; then
	EXT_TMP=/tmp/extensions.tmp
	echo $EXTENSIONS | sed 's/,/\n/g' >> ${EXT_TMP}
	echo -e "`date -d now +"%T"` -- Empezamos el Fuzzing (EXT) via Bing ...\n"
	cat ${EXT_TMP} | xargs -n1 -P${THREADS} bash -c 'i=$0; url="https://www.bing.com/search?q=domain%3a'${URL}'%20ext%3a${i}&first=1"; echo -e "`date -d now +"%T"` -- Buscando con la palabra ${i}..." ; curl -s $url | grep -Po "(?<=<a href=\").*?(?=\" h=)" | grep -Po "https?.*" | grep ${URL}' >> ${FICH_TEMP}
	echo -e "Proceso Finalizado el resultado es el siguiente:\n"
	cat ${FICH_TEMP} | sort | uniq | tee -a ${FICHERO}
	echo -e "Tambien puedes encontar el resulto completo en ${FICHERO}\n"
	rm -fr ${FICH_TEMP}
	rm -fr ${EXT_TMP}
	exit ${STATE_OK}

fi



#while read palabra; do
#	echo -e "`date -d now +"%T"` -- Buscando la palabra ${palabra}\n"
#	#curl  "https://www.bing.com/search?q=domain%3a${URL}%20${palabra}&first=1" -s |  grep -Po "(?<=<a href=\").*?(?=\" h=)" | egrep -v "microsoft|bing|pointdecontact" | grep -Po "https?.*"  | grep ${URL} >> ${FICH_TEMP}
#	xargs -n1 -P${THREADS} bash -c 'i=$0; url="https://www.bing.com/search?q=domain%3a'${URL}'%20${palabra}&first=1"; curl -s $url | grep -Po "(?<=<a href=\").*?(?=\" h=)" | egrep -v "microsoft|bing|pointdecontact|youtube\.com" | grep -Po "https?.*" | grep "'${URL}'"' >> ${FICH_TEMP}
#done < ${DICC}

#echo -e "Proceso Finalizado el resultado es el siguiente:\n"
#cat ${FICH_TEMP} | sort | uniq | tee -a ./${FICHERO}
#echo "Tambien puedes encontar el resulto completo en ${FICHERO}"
#
#rm -fr ${FICH_TEMP}