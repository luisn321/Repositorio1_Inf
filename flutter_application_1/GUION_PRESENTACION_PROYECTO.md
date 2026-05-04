# Guion de Presentación del Proyecto: Servitec

Este documento sirve como guía para la exposición del proyecto final ante la clase y el docente. Está estructurado para cubrir todos los puntos solicitados: demostración en tiempo real, explicación del código, arquitectura del sistema y cumplimiento de requerimientos.

---

## 1. Introducción (2 minutos)
*   **Presentación del equipo y del proyecto**: "Buenos días/tardes. Presentamos **Servitec**, una plataforma móvil diseñada para conectar clientes con técnicos especializados."
*   **Objetivo**: Mostrar cómo logramos digitalizar el proceso de contratación de servicios, desde la búsqueda hasta el pago y la calificación, cumpliendo con los requerimientos planteados al inicio del semestre.
*   **Tecnologías Clave**: 
    *   Frontend: Flutter (Dart)
    *   Backend: C# .NET 8.0 (API REST)
    *   Base de Datos: MySQL alojada en la nube (Aiven)
    *   Despliegue: Docker y Render

---

## 2. Demostración en Tiempo Real (Flujo del Sistema) (5-7 minutos)
*Durante esta sección, un miembro del equipo debe operar la aplicación (en el celular o emulador) mientras otro explica lo que está sucediendo.*

### A. Registro y Autenticación (RF-01, RF-02)
*   **Acción**: Mostrar la pantalla de Login y crear un usuario nuevo (Cliente o Técnico).
*   **Explicación**: El sistema diferencia entre Clientes y Técnicos. Las contraseñas se almacenan cifradas en la base de datos por seguridad.

### B. Perfiles y Servicios (RF-03, RF-04, RF-06)
*   **Acción**: Iniciar sesión como Técnico, mostrar el perfil y cómo se agregan/editan los servicios ofrecidos (ej. Plomería, Carpintería).
*   **Explicación**: Los técnicos pueden personalizar su perfil, subir fotos reales a través de Cloudinary, y establecer tarifas base.

### C. Flujo de Solicitud de Servicio (RF-07 a RF-13)
*   **Acción**: 
    1. Iniciar sesión como Cliente.
    2. Buscar un técnico y solicitar un servicio, eligiendo fecha y hora.
    3. Cambiar a la vista del Técnico: mostrar la notificación de nueva solicitud y *aceptarla* proponiendo un precio final, o proponer una *nueva fecha*.
*   **Explicación**: El sistema maneja un ciclo de vida completo de estados (Pendiente, Aceptada, Rechazada, Cancelada) garantizando la comunicación bidireccional.

### D. Pago y Calificación (RF-14 a RF-18)
*   **Acción**: El Cliente acepta el precio, registra el pago (estado "Pagado") y, al finalizar el trabajo, califica al técnico.
*   **Explicación**: Se mantiene un historial en tiempo real. La calificación afecta el promedio público del técnico, generando un sistema de confianza.

---

## 3. Explicación de las Principales Funcionalidades en el Código (5 minutos)
*En esta sección, abran el editor de código (VS Code/Android Studio) y muestren partes específicas del desarrollo.*

### Frontend (Flutter - Móvil)
*   **Arquitectura Modular (RNF-CAL-03)**: Mostrar la estructura de la carpeta `lib/` separada en `Screens`, `modelos`, `servicios_red`, y `utilidades`. 
*   **Consumo de API (`api.dart`)**: Explicar cómo la clase `ApiService` centraliza todas las peticiones `http` (GET, POST, PUT) hacia nuestro servidor en la nube.
*   **Manejo de Estado y UI**: Mostrar cómo se usan los `FutureBuilder` para cargar datos asíncronos y componentes reutilizables como los diálogos de alerta (`dialogos_solicitudes.dart`).

### Backend (C# .NET 8.0 - Servidor)
*   **Controladores (`Controllers/`)**: Mostrar un controlador (ej. `AuthController` o `ContractionsController`) y explicar cómo reciben las peticiones HTTP y responden en formato JSON.
*   **Inyección de Dependencias y Servicios (`Services/`)**: Destacar la separación de lógica de negocio usando interfaces (ej. `IServiceService`, `IAuthService`).
*   **Seguridad y JWT (RNF-SEG-01, 02)**: Mostrar cómo el método de login genera un **JSON Web Token (JWT)** para proteger las rutas, y cómo `BCrypt` encripta las contraseñas antes de guardarlas en MySQL.

---

## 4. Desarrollo e Integración del Sistema (3 minutos)
*Explicar cómo se unieron todas las piezas del rompecabezas para llevar el proyecto a producción.*

1.  **Base de Datos en la Nube (Aiven)**: Pasamos de usar una base local (XAMPP/Workbench) a una en la nube. Esto permite que cualquier dispositivo pueda consumir los datos en tiempo real.
2.  **Manejo de Imágenes (Cloudinary)**: Integramos la API de Cloudinary para que las fotos de perfil y evidencias no saturen nuestra base de datos, sino que se guarden en un servidor optimizado para imágenes, retornando solo la URL segura.
3.  **Contenedores y Despliegue (Docker + Render)**: Explicar brevemente el `Dockerfile`. Empaquetamos nuestro backend de C# en un contenedor para garantizar que funcione en cualquier entorno. Finalmente, lo desplegamos en **Render** obteniendo una URL pública (`https://...`).

---

## 5. Cumplimiento de Requerimientos (2 minutos)
*Para cerrar, justifiquen cómo el proyecto presentado cumple con el documento de planeación original.*

*   **Funcionales**: Se implementaron todos los flujos solicitados (RF-01 a RF-18), abarcando desde el registro inicial hasta el registro de pagos y calificaciones.
*   **No Funcionales (Desempeño y Calidad)**: 
    *   La App es rápida y fluida gracias a Flutter.
    *   Las validaciones impiden errores críticos (RNF-ERR-04).
    *   El diseño se adapta a dispositivos móviles modernos.
*   **Seguridad**: Uso de JWT, contraseñas encriptadas con Hash, y URLs HTTPS (RNF-SEG).
*   **Seudorrequerimientos**: Completado en el tiempo del curso usando tecnologías modernas y de nivel industrial (C#, Flutter, Nube).

---

## 6. Conclusión
"Con Servitec, logramos crear un sistema completo de principio a fin (End-to-End). Aprendimos a conectar una aplicación móvil multiplataforma con un robusto backend en C# y una base de datos en la nube, solucionando un problema real de contratación de servicios. 

Gracias por su atención. Estamos abiertos a cualquier pregunta sobre la implementación o el funcionamiento."
