#!/bin/sh
sleep 1
echo "HELO [tu servidor de correo ej mail.miserver.com]"
sleep 1
echo "MAIL FROM: soporte@miserver.com"
sleep 1
echo "RCPT TO: administrador1@miserver.com"
sleep 1
echo "RCPT TO: administrador2@miserver.com"
sleep 1
echo "RCPT TO: administrador3@miserver.com"
sleep 1
echo "RCPT TO: administrador4@miserver.com"
sleep 1
echo "DATA"
sleep 1
echo "From: Soporte TICs <soporte@miserver.com>"                                       
echo "To: administrador1 <administrador1@miserver.com>,administrador2 <administrador2@miserver.com>,administrador3<administrador3@miserver.com>,administrador4<administrador4@miserver.com>"
echo "Subject: Notificacion de Bloqueo de Salida del Servidore de Correo"
echo "Se Informa que se ha bloqueado la salida del servidor a correos externos por que se supero el limite maximo de envios por dia"
echo "<br>Se recomienda revisar el servidor de correo"
echo "."                                    #end of DATA character
sleep 1
echo "QUIT" 
