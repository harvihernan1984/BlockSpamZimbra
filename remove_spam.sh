#!/bin/bash
rm salida_spam.txt
date
echo "eliminando log anterior"
echo "capturando log de cola"
date
/opt/zimbra/common/sbin/postqueue -p | grep nikol.castro  >> salida_spam.txt
echo "finalizo captura de log"
date
salidaLog=/opt/script/salida_spam.txt
echo "Iniciamos  procesamiento"
itera=0
cat $salidaLog | while read LINEA ;
do
	fila=$LINEA
	codigo=`echo $LINEA | cut -d " " -f1`
	/opt/zimbra/common/sbin/postsuper -d $codigo
	echo "removiendo $itera codigo $codigo"
	itera=$((itera + 1))
done
echo "Proceso finalizado....."
