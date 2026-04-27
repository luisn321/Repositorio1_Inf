Requerimientos funcionales:
El sistema deberá permitir el registro de usuarios mediante un formulario que solicite como 
mínimo: nombre completo, correo electrónico válido, contraseña y tipo de usuario (cliente o 
técnico). 
• RF-02. Autenticación. 
El sistema deberá permitir a los usuarios autenticarse mediante correo electrónico y contraseña. 
• RF-03. Edición de perfil. 
El sistema deberá permitir que los usuarios actualicen su información personal y fotografía de 
perfil. 
• RF-04. Registro de servicios ofrecidos. 
El sistema deberá permitir que el técnico registre los servicios que ofrece, incluyendo 
descripción y precio base estimado. 
• RF-05. Gestión de disponibilidad. 
El sistema deberá permitir que el técnico registre y actualice su disponibilidad de fechas y 
horarios. 
• RF-06. Visualización de perfil público. 
El sistema deberá mostrar a los clientes el perfil público del técnico, incluyendo servicios 
ofrecidos, descripción, calificación promedio y comentarios recibidos. 
• RF-07. Creación de solicitud. 
El sistema deberá permitir que un cliente genere una solicitud de servicio seleccionando un 
técnico, describiendo el problema y proponiendo fecha y hora. 
• RF-08. Notificación al técnico. 
El sistema deberá notificar al técnico cuando reciba una nueva solicitud de servicio. 
• RF-09. Aceptación de solicitud. 
El sistema deberá permitir que el técnico acepte una solicitud e ingrese el monto final del 
servicio. 
• RF-10. Rechazo de solicitud. 
El sistema deberá permitir que el técnico rechace una solicitud indicando el motivo del rechazo. 
• RF-11. Propuesta alternativa de fecha. 
El sistema deberá permitir que el técnico proponga una nueva fecha y hora en caso de no poder 
atender la solicitud en el horario solicitado. 
• RF-12. Confirmación del cliente. 
El sistema deberá permitir que el cliente acepte o rechace la propuesta alternativa del técnico. 
• RF-13. Cancelación automática. 
El sistema deberá cancelar automáticamente la solicitud si el cliente rechaza la propuesta 
alternativa del técnico. 
• RF-14. Registro de pago. 
El sistema deberá permitir que el cliente registre el pago del servicio una vez que haya aceptado 
el monto establecido por el técnico. 
• RF-15. Confirmación de pago. 
El sistema deberá cambiar el estado de la solicitud a “Pagado” una vez confirmado el registro 
del pago. 
• RF-16. Actualización de estado del servicio. 
El sistema deberá permitir que el técnico actualice el estado del servicio a “En proceso” y 
posteriormente a “Completada”. 
• RF-17. Historial de solicitudes. 
El sistema deberá permitir que tanto cliente como técnico consulten el historial de solicitudes 
realizadas o atendidas. 
• RF-18. Estados de solicitud. 
El sistema deberá manejar los siguientes estados de solicitud: Aceptada, Cancelada, En proceso 
y Completada.

Requerimientos no funcionales: 
3.3.3 Consideraciones de hardware. 
• RNF-HW-01. Dispositivo móvil compatible. 
La aplicación deberá ejecutarse en dispositivos móviles con sistema operativo Android versión 
8.0 o superior. 
• RNF-HW-02. Memoria RAM mínima. 
La aplicación deberá funcionar correctamente en dispositivos con al menos 2 GB de memoria 
RAM. 
• RNF-HW-03. Espacio de almacenamiento. 
La aplicación deberá requerir un espacio de almacenamiento no mayor a 150 MB para su 
instalación y funcionamiento básico. 
• RNF-HW-04. Conectividad a internet. 
El dispositivo deberá contar con conexión a internet (Wi-Fi o datos móviles) para realizar 
registro, solicitudes, actualizaciones de estado y pagos. 
• RNF-HW-05. Servidor backend. 
El sistema deberá ejecutarse sobre un servidor que permita almacenar información de usuarios, 
solicitudes y calificaciones de manera persistente. 
3.3.4 Características de desempeño. 
• RNF-REN-01. Tiempo de respuesta en autenticación 
El sistema deberá procesar la autenticación de usuarios en un tiempo máximo de 5 segundos 
bajo condiciones normales de red. 
• RNF-REN-02. Tiempo de carga de solicitudes. 
El sistema deberá mostrar el listado de solicitudes en un tiempo máximo de 5 segundos cuando 
exista conexión estable a internet. 
• RNF-REN-03. Tiempo de actualización de estado. 
El sistema deberá actualizar el estado de una solicitud en un tiempo máximo de 5 segundos 
después de que el usuario confirme la acción. 
• RNF-REN-04. Soporte de usuarios concurrentes. 
El sistema deberá soportar al menos 100 usuarios concurrentes sin degradación significativa del 
servicio en su primera versión. 
• RNF-REN-05. Carga de imágenes. 
El sistema deberá permitir la carga de imágenes de evidencia con un tamaño máximo de 5 MB 
por archivo. 
• RNF-REN-06. Disponibilidad operativa. 
El sistema deberá mantener una disponibilidad mínima del 95% mensual, excluyendo periodos 
de mantenimiento programado. 
3.3.5 Manejo de errores y condiciones extremas. 
• RNF-ERR-01. Pérdida de conexión a internet. 
El sistema deberá mostrar un mensaje informativo cuando no exista conexión a internet e 
impedir la ejecución de operaciones que requieran comunicación con el servidor. 
• RNF-ERR-02. Credenciales incorrectas. 
El sistema deberá mostrar un mensaje de error específico cuando el usuario ingrese credenciales 
inválidas sin revelar información sensible. 
• RNF-ERR-03. Fallo en registro de pago. 
En caso de error durante el registro del pago, el sistema deberá notificar al usuario y mantener 
el estado de la solicitud sin cambios hasta que se confirme el pago exitosamente. 
• RNF-ERR-04. Campos incompletos. 
El sistema deberá impedir el envío de formularios cuando existan campos obligatorios vacíos y 
deberá indicar cuáles requieren corrección. 
RNF-ERR-05. Fallo del servidor. 
Si el servidor no responde, el sistema deberá mostrar un mensaje indicando que el servicio no 
está disponible temporalmente y permitir reintentar la operación. 
RNF-ERR-06. Manejo de imágenes inválidas. 
El sistema deberá rechazar imágenes que superen el tamaño permitido o no correspondan a 
formatos aceptados (JPG o PNG). 
3.3.6 Cuestiones de calidad. 
• RNF-CAL-01. Confiabilidad. 
El sistema deberá mantener la integridad de los datos de usuarios, solicitudes, pagos y 
calificaciones sin pérdida o alteración no autorizada de información. 
• RNF-CAL-02. Integridad de datos. 
El sistema deberá validar que no existan solicitudes duplicadas generadas por el mismo usuario 
en un intervalo menor a 1 minuto. 
• RNF-CAL-03. Mantenibilidad. 
El sistema deberá estructurarse en módulos separados (interfaz, lógica de negocio y acceso a 
datos) para facilitar futuras modificaciones o mejoras. 
• RNF-CAL-04. Escalabilidad inicial. 
La arquitectura del sistema deberá permitir la ampliación futura de funcionalidades sin requerir 
rediseño completo del sistema. 
• RNF-CAL-05. Portabilidad. 
La aplicación deberá desarrollarse utilizando Flutter, permitiendo su posible adaptación futura 
a otros sistemas operativos móviles sin reescritura total del código. 
• RNF-CAL-06. Recuperación ante fallos. 
El sistema deberá conservar el estado de la solicitud si la aplicación se cierra inesperadamente 
y permitir continuar el proceso al reabrirse. 
• RNF-CAL-07. Consistencia de información. 
La información mostrada en el historial de solicitudes deberá coincidir con los estados 
registrados en la base de datos. 
3.3.7 Modificaciones al sistema. 
• RNF-MOD-01. Arquitectura modular. 
El sistema deberá estar estructurado en componentes independientes (interfaz, lógica de negocio 
y acceso a datos) para permitir modificaciones sin afectar el funcionamiento general. 
• RNF-MOD-02. Control de versiones. 
Toda modificación al código fuente deberá registrarse mediante un sistema de control de 
versiones que permita identificar cambios realizados y restaurar versiones anteriores. 
• RNF-MOD-03. Compatibilidad retroactiva. 
Las actualizaciones del sistema no deberán afectar el acceso a la información previamente 
almacenada en la base de datos. 
• RNF-MOD-04. Gestión de cambios. 
Toda modificación a los requerimientos funcionales deberá documentarse formalmente antes de 
su implementación. 
• RNF-MOD-05. Pruebas posteriores a modificación. 
Cada modificación realizada deberá validarse mediante pruebas funcionales antes de ser 
liberada a los usuarios. 
3.3.8 Ambiente físico. 
• RNF-AF-01. Uso en dispositivos móviles personales. 
El sistema deberá operar en dispositivos móviles personales de los usuarios (clientes y técnicos), 
sin requerir equipamiento especializado adicional. 
• RNF-AF-02. Uso en entornos variables. 
La aplicación deberá funcionar correctamente en entornos interiores y exteriores donde exista 
conectividad a internet. 
• RNF-AF-03. Dependencia de conectividad. 
El sistema requerirá conexión activa a internet para la creación, actualización y consulta de 
solicitudes de servicio. 
• RNF-AF-04. Operación durante jornadas laborales variables 
El sistema deberá permitir su uso en horarios flexibles definidos por cada técnico, sin 
restricciones de horario impuestas por la aplicación. 
3.3.9 Cuestiones de seguridad. 
• RNF-SEG-01. Protección de credenciales. 
El sistema deberá almacenar las contraseñas de los usuarios utilizando mecanismos de cifrado 
seguro (hash). 
• RNF-SEG-02. Acceso autenticado. 
El sistema deberá permitir el acceso a funcionalidades sensibles únicamente a usuarios 
previamente autenticados. 
• RNF-SEG-03. Separación de roles. 
El sistema deberá restringir las funciones disponibles según el tipo de usuario (cliente o técnico). 
• RNF-SEG-04. Protección de datos personales 
El sistema deberá almacenar los datos personales de los usuarios en una base de datos protegida 
contra accesos no autorizados. 
• RNF-SEG-05. Protección en comunicación. 
El sistema deberá utilizar comunicación segura mediante protocolo HTTPS para el intercambio 
de información con el servidor. 
• RNF-SEG-06. Protección contra manipulación de estados. 
El sistema deberá validar en el servidor cualquier cambio de estado de una solicitud para evitar 
manipulaciones desde el dispositivo cliente. 
• RNF-SEG-07. Eliminación de cuenta. 
El sistema deberá permitir que el usuario solicite la eliminación de su cuenta, eliminando sus 
datos personales de la base de datos conforme a la normativa aplicable. 
3.3.10 Cuestiones de recursos. 
• RNF-REC-01. Recursos de desarrollo. 
El sistema deberá desarrollarse utilizando el framework Flutter y un backend compatible con 
bases de datos relacionales o NoSQL. 
• RNF-REC-02. Infraestructura de servidor. 
El sistema deberá contar con un servidor en la nube que permita el almacenamiento de datos y 
la gestión de solicitudes en tiempo real. 
• RNF-REC-03. Base de datos. 
El sistema deberá utilizar una base de datos que permita almacenar información de usuarios, 
solicitudes, estados, pagos y calificaciones de manera estructurada. 
• RNF-REC-04. Conectividad. 
El sistema requerirá conexión a internet para la operación de funcionalidades principales como 
autenticación, registro de solicitudes y actualización de estados. 
• RNF-REC-05. Recursos humanos. 
El desarrollo del sistema deberá realizarse por el equipo asignado en la materia, distribuyendo 
responsabilidades de análisis, diseño, desarrollo y pruebas. 
• RNF-REC-06. Recursos de almacenamiento. 
El sistema deberá permitir almacenamiento de imágenes de perfil y fotografías del servicio con 
un límite máximo de 5 MB por imagen. 
3.4 Seudorrequerimientos. 
Los siguientes seudorrequerimientos establecen restricciones y condiciones externas que 
influyen en el desarrollo del sistema, pero que no representan funcionalidades directas del 
mismo. 
• SR-01. Plataforma tecnológica definida. 
El sistema deberá desarrollarse utilizando el framework Flutter como tecnología principal de 
desarrollo móvil. 
• SR-02. Duración del proyecto. 
El desarrollo del sistema deberá completarse en un periodo máximo de 2 meses conforme al 
calendario académico. 
• SR-03. Entrega académica. 
El proyecto deberá entregarse en formato digital (documentación y aplicación funcional) y 
presentarse ante el grupo en la fecha establecida por el docente. 
• SR-04. Firma de visto bueno del cliente. 
El documento de análisis de requerimientos deberá incluir la firma de aprobación del cliente 
definido para el proyecto. 
• SR-05. Alcance limitado. 
El sistema no incluirá en esta versión funcionalidades avanzadas como geolocalización 
automática, pagos integrados con instituciones bancarias reales o sistemas de facturación fiscal. 
• SR-06. Uso de herramientas accesibles. 
El desarrollo deberá realizarse utilizando herramientas gratuitas o de acceso académico. 
• SR-07. Implementación incremental. 
Las funcionalidades del sistema podrán implementarse de manera incremental, siempre que la 
versión final cumpla con los requerimientos establecidos en este documento.