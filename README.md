# BlockSpamZimbra
Conjunto de Script para bloquear y controlar la salida de Correo Spam Ante Un Ataque.

Ante los recientes ataques presentados en un servidor de correo electrónico el cual administro, que utiliza la plataforma Zimbra.
Al cual se le han implementado algunas estrategias con el objetivo de impedir el ataque de correos Spam.

Una vez que se realizó un análisis de las soluciones ofertadas en el mercado, las cuales no garantizan al 100% el bloqueo de SPAM y que su ves son considerablemente costosas, se optó por crear un programa que permita controlar esta situación, mediante la siguiente estrategia.

1) Realizar una lectura del log del Zimbra de forma periódica para obtener información de cuantos correos se están enviando, esta información almacenarla en una base de datos.
2) una vez almacenad esta información se realiza la respectiva validación de cuantos correos salen a un dominio diferente al nuestro.
3) con esta información se valida si el número de correos es superior a un límite establecido y ejecuta un comando de bloqueo de salida y se envía una notificación a las cuentas de los administradores de que el servicio está bloqueado.
4) una vez que se bloquea el servicio de salida los administradores deberán revisar las colas de correo y eliminar los correos que se consideren SPAM.


 
