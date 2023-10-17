#!/bin/bash
#removemos el contenido de la salida del log del zimbnra
date
echo "Removiendo log antiguo"
rm /opt/script/salida.txt
#ejecutamos la lectura del log y lo almacenamos en el archivo salida.txt
echo "Generando nuevo log"
less /var/log/zimbra.log | grep -e "FWD from <.*> ->.*:10025):" -e  "FWD from <> ->.*:10025):" >> /opt/script/salida.txt
#ahora preparamos el archivo
echo "Preprando el log para consolidar"
sed -i 's/mail amavis/;/g' /opt/script/salida.txt
sed -i 's/FWD from </;/g' /opt/script/salida.txt
sed -i 's/> -> </;/g' /opt/script/salida.txt
sed -i 's/250 2.0.0 from MTA(smtp:/;/g' /opt/script/salida.txt
sed -i 's/>, BODY=/;/g' /opt/script/salida.txt
sed -i 's/Ok: queued as /;/g' /opt/script/salida.txt
#sed -i 's/>,</ /g' /opt/script/salida.txt
#creamos una funcion para separar los destibnos
get_destinos(){
	return $#
}
total_correos_fun(){
	para=$1
	resul=$(echo $para | sed  's/>,</ /g')
	get_destinos $resul
	num_ele=$?
	#echo "parametros= $resul"
	#echo "num ele= $num_ele"
	#echo "num _elementos ${#resul[@]}"
	return  $num_ele
}
correos_locales_fun(){
        para=$1
        resul=$(echo $para | sed  's/@mspz4.gob.ec/ /g')
        get_destinos $resul
        num_ele=$?
        #echo "parametros= $resul"
        #echo "num ele= $num_ele"
        #echo "num _elementos ${#resul[@]}"
        return  $num_ele
}
#ahora debemos recorrer el archivo salida fila a fila
salidaLog=/opt/script/salida.txt
num_lineas=$(wc -l < /opt/script/salida.txt)
echo "numero de registros= $num_lineas"
itera=0
nuevos=0
reg=100
fecha=$(echo "$(date)")
ano=`echo $fecha | cut -d " " -f4`
mes2=`echo $fecha | cut -d " " -f3`
dia2=`echo $fecha | cut -d " " -f2`
num_reg=$(sqlite3 /opt/script/DBZIMBRA.DB "select count(*) from correo where lower(fecha)=lower('$mes2 $dia2 $ano') ")
num_filas=$(sqlite3 /opt/script/DBZIMBRA.DB "select coalesce((select idfila from registros where lower(fecha)=lower('$mes2 $dia2 $ano')),0)")
if [ $num_filas -eq 0 ] ; then
	sqlite3 /opt/script/DBZIMBRA.DB "INSERT INTO registros (idfila,fecha) VALUES($num_lineas,lower('$mes2 $dia2 $ano'))"
else
	sqlite3 /opt/script/DBZIMBRA.DB "UPDATE registros set idfila=$num_lineas where lower(fecha)=lower('$mes2 $dia2 $ano')"
fi
echo "Iniciamos  procesamiento"
cat $salidaLog | while read LINEA ;
do
	if [ $itera -gt $num_filas ] ; then
		fila=$LINEA
		mes=`echo $LINEA | cut -d " " -f1`
		dia=`echo $LINEA | cut -d " " -f2`
		hora=`echo $LINEA | cut -d " " -f3`
		cuenta=`echo $LINEA | cut -d ";" -f3`
		destinos=`echo $LINEA | cut -d ";" -f4`
		campo5=`echo $LINEA | cut -d ";" -f5` # no aplica
		campo6=`echo $LINEA | cut -d ";" -f6`
		idcorreo=`echo $LINEA | cut -d ";" -f7`
		#mes = `echo $campo1 | cut -d " " -f1`
		#dia = `echo $campo1 | cut -d " " -f2`
		#echo $destinos | sed -e "/>,</ /g"
		#echo "coreros= $destinos"
		total_correos_fun $destinos
		num_dest=$?
		correos_locales_fun $destinos
		num_local=$?
		if [ $num_local -eq 1 ]; then
			aux=$(echo $destinos | grep -c "@miserver.com")
			if [ $aux -eq 0 ]; then
				num_local=0
			fi
		fi
		#echo  "mes = $mes dia= $dia cuenta= $cuenta destinos= $destinos idcorreo=$idcorreo num-dest= $num_dest"
		#echo "campo 7 = $campo7"
		#echo "num destinos= $nun"
		existe=$(sqlite3 /opt/script/DBZIMBRA.DB "select count(*) from correo where fecha='$mes $dia $ano' and idcorreo='$idcorreo'")
		#echo "registro = $existe"
		if [ $existe -eq 0 ]; then
			sqlite3 /opt/script/DBZIMBRA.DB "insert into correo VALUES('$cuenta','$mes $dia $ano','$destinos',$num_dest,'$hora',$num_local,'','$idcorreo')"
			nuevos=$((nuevos + 1))
		fi
	fi
	itera=$((itera + 1))
	resto=$((itera%reg))
	#echo "residuo=$resto"
	#echo  -n "cuenta=$cuenta -> destinos= $destinos"\\r
	if [ $itera -gt $num_filas ] ; then
		if [ $resto -eq 0 ]; then 
			#echo  "cuenta=$cuenta -> destinos= $destinos"
			echo -n "Procesando ... $itera    Nuevos= $nuevos"\\r
		fi
	fi
done
echo "Procesando ... 100% "
echo "Proceso finalizado....."
sh /opt/script/reporte_monitor.sh fecha
