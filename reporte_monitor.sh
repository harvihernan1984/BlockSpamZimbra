#!/bin/bash
#parametro=$1
#date
limite_diario=400
if [ ! -z $1  ] ; then
	fecha=$(echo "$(date)")
	echo "Reporte= $fecha"
	dic="dic";
	ene="ene";
	abr="abr"
	mes=`echo $fecha | cut -d " " -f3`
	dia=`echo $fecha | cut -d " " -f2`
	ano=`echo $fecha | cut -d " " -f4`
	dia=$((dia + 0))
	if [ "$mes" = "$dic" ]; then 
		mes="Dec";
	fi
	if [ "$mes" = "$ene" ]; then
                mes="Jan";
        fi
	if [ "$mes" = "$abr" ]; then
                mes="Apr";
        fi
	echo "mes=$mes dia=$dia año=$ano"
	salida=$(sqlite3 /opt/script/DBZIMBRA.DB "select 'Fecha: ' || fecha || ' Total coreos=' || sum(num_local) || ' Correos externos=' ||(sum(num_local) - sum(num_ext)) from consolidado group by fecha HAVING lower(fecha)=lower('$mes $dia $ano') ")
	echo  "Salida:$salida"
	ext=`echo $salida | cut -d "=" -f3`
	#echo  "externos= $ext"
	resul=$((ext + 1))
	#echo  "Corre=$resul"
	if [ $resul -gt $limite_diario ]; then
		noti=$(sqlite3 /opt/script/DBZIMBRA.DB "select count(*) from notificacion where fecha='$mes $dia $ano'")
		if [ $noti -eq 0 ] ; then
			sudo ufw default deny outgoing
			echo "Servidor Bloqueado limite maximo de envios a correos externos Superado"
			echo "Servidor bloqueado $fecha" >> /opt/script/registro_bloqueos.txt
			sh /opt/script/envia_correo.sh | telnet 127.0.0.1 25
			sqlite3 /opt/script/DBZIMBRA.DB "INSERT INTO notificacion (fecha,evento) VALUES('$mes $dia $ano',1)"
			#enviamos la notificacion de que el servidor esta bloqueado cada media hora
		else
			evento=$(sqlite3 /opt/script/DBZIMBRA.DB "select evento from notificacion where fecha='$mes $dia $ano'")
			#sudo ufw default deny outgoing
			echo  "entro aca $evento"
			resto2=$((evento%10))
			if [ $resto2 -eq 0 ]; then
				sh /opt/script/envia_correo.sh | telnet 127.0.0.1 25 
				echo "se envio correo"
			fi
			sqlite3 /opt/script/DBZIMBRA.DB "update notificacion set evento=evento + 1 where fecha='$mes $dia $ano'"
		fi
	else
		echo "limite diario= $limite_diario"
	fi
else
	sqlite3 /opt/script/DBZIMBRA.DB "select 'Fecha: ' || fecha || ' Total coreos=' || sum(num_local) || ' Correos externos=' ||(sum(num_local) - sum(num_ext)) from consolidado  group by fecha"
fi
#reporte=$(sqlite3 /opt/script/DBZIMBRA.DB "select fecha,sum(num_local) as total_coreo,sum(num_local) - sum(num_ext) as correos_ext from consolidado group by fecha")
#sqlite3 /opt/script/DBZIMBRA.DB "select 'Fecha: ' || fecha ,'Total coreos=' || sum(num_local) ,'Correos externos=' ||(sum(num_local) - sum(num_ext)) from consolidado group by fecha"

#echo $reporte;
