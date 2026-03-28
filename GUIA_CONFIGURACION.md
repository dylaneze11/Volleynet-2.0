# 📱 VolleyNet — Guía de Configuración Completa
### Para personas sin experiencia en programación

---

> **¿Qué vas a lograr al seguir esta guía?**
> Al terminar, tendrás VolleyNet corriendo en tu navegador web, lista para usar.
> Tiempo estimado: **20 a 30 minutos**.

---

## 🧰 REQUISITOS PREVIOS

Antes de empezar, asegurate de tener instalado en tu computadora:

- **Google Chrome** (navegador)
- El proyecto VolleyNet en la carpeta `F:\Proyectos\Proyecto de dylan\volleynet`

Todo lo demás lo instalaremos juntos en esta guía.

---

## PARTE 1 — Crear el proyecto en Firebase (el "servidor" de la app)

Firebase es el servicio de Google que maneja los usuarios, las publicaciones y los
mensajes de VolleyNet. Es **gratuito** para empezar.

---

### Paso 1 · Crear una cuenta de Google (si no tenés una)

1. Abrí Google Chrome.
2. Andá a **[https://accounts.google.com](https://accounts.google.com)**
3. Si ya tenés Gmail u otra cuenta de Google, usá esa directamente.

---

### Paso 2 · Crear el proyecto en Firebase Console

1. Abrí **[https://console.firebase.google.com](https://console.firebase.google.com)**
2. Iniciá sesión con tu cuenta de Google.
3. Hacé clic en el botón **"Crear un proyecto"** (o "Add project" si está en inglés).

   ![Botón Crear proyecto](https://i.imgur.com/placeholder.png)

4. En el campo **"Nombre del proyecto"**, escribí: `volleynet`
5. Hacé clic en **"Continuar"**.
6. En la pantalla de Google Analytics, podés desactivarlo (toggle en "off") y hacer clic en **"Crear proyecto"**.
7. Esperá unos segundos mientras Firebase crea el proyecto.
8. Cuando aparezca el mensaje **"Tu nuevo proyecto está listo"**, hacé clic en **"Continuar"**.

   ✅ Ya tenés el proyecto creado.

---

### Paso 3 · Habilitar la Autenticación (para que los usuarios puedan registrarse)

1. En la pantalla principal de tu proyecto, en el **menú de la izquierda**, buscá y hacé clic en **"Authentication"** (ícono de persona).
2. Hacé clic en **"Comenzar"** o **"Get started"**.
3. Vas a ver una lista de métodos de inicio de sesión. Hacé clic en **"Correo electrónico/contraseña"**.
4. Activá el primer toggle (el que dice "Habilitar" o "Enable").
5. Hacé clic en **"Guardar"**.

   ✅ Los usuarios ya podrán registrarse con email y contraseña.

---

### Paso 4 · Crear la base de datos Firestore (donde se guardan posts, perfiles, etc.)

1. En el **menú de la izquierda**, hacé clic en **"Firestore Database"**.
2. Hacé clic en **"Crear base de datos"** o **"Create database"**.
3. Elegí la opción **"Iniciar en modo de prueba"** (Start in test mode).
   > ⚠️ Esto permite acceso libre durante 30 días. Está bien para empezar. Después
   > podés configurar reglas de seguridad más estrictas.
4. Hacé clic en **"Siguiente"**.
5. En "Ubicación de Cloud Firestore", elegí **`us-east1`** (o la más cercana a tu país).
6. Hacé clic en **"Listo"** o **"Enable"**.
7. Esperá unos segundos a que se cree la base de datos.

   ✅ La base de datos está lista.

---

### Paso 5 · Crear el Storage (donde se guardan las fotos y videos)

1. En el **menú de la izquierda**, hacé clic en **"Storage"**.
2. Hacé clic en **"Comenzar"** o **"Get started"**.
3. Seleccioná **"Iniciar en modo de prueba"** y hacé clic en **"Siguiente"**.
4. Elegí la misma ubicación que elegiste para Firestore.
5. Hacé clic en **"Listo"**.

   ✅ El almacenamiento de archivos está listo.

---

### Paso 6 · Obtener las credenciales de tu proyecto Firebase

Ahora necesitamos "conectar" la app con tu proyecto Firebase. Para eso necesitamos
las credenciales (claves de configuración).

1. Hacé clic en el **ícono de engranaje ⚙️** (arriba a la izquierda, al lado de "Project Overview").
2. Seleccioná **"Configuración del proyecto"**.
3. En la página que se abre, bajá hasta la sección **"Tus apps"**.
4. Hacé clic en el ícono **`</>`** (que representa una app web).
5. En "Apodo de la app", escribí: `volleynet-web`
6. **No** marques la opción de Firebase Hosting.
7. Hacé clic en **"Registrar app"**.
8. Se va a mostrar un bloque de código. Vas a necesitar los valores de:
   - `apiKey`
   - `authDomain`
   - `projectId`
   - `storageBucket`
   - `messagingSenderId`
   - `appId`

   **Dejá esta ventana abierta**, la vas a necesitar en el siguiente paso.

---

## PARTE 2 — Conectar la app con Firebase

---

### Paso 7 · Abrir el archivo de configuración de la app

1. Abrí el **Explorador de archivos** de Windows.
2. Navegá a: `F:\Proyectos\Proyecto de dylan\volleynet\lib\`
3. Buscá el archivo llamado **`main.dart`**.
4. Hacé **clic derecho** sobre ese archivo → **"Abrir con"** → **"Bloc de notas"** (o cualquier editor de texto).

---

### Paso 8 · Reemplazar las credenciales

Dentro del archivo `main.dart`, vas a encontrar este bloque (aproximadamente en la línea 14):

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_BUCKET',
    authDomain: 'REPLACE_WITH_YOUR_AUTH_DOMAIN',
  ),
);
```

**Reemplazá cada valor** (lo que está entre comillas simples `' '`) con el valor
que aparece en la pantalla de Firebase. Por ejemplo, si tu `apiKey` en Firebase
es `AIzaSyABC123...`, la línea quedaría así:

```dart
apiKey: 'AIzaSyABC123...',
```

Hacé lo mismo para cada campo (`authDomain`, `projectId`, `storageBucket`, `messagingSenderId`, `appId`).

Cuando termines, **guardá el archivo** (Ctrl + S).

---

## PARTE 3 — Abrir la app en el navegador

---

### Paso 9 · Abrir una terminal (consola de comandos)

1. Presioná las teclas **Windows + R** al mismo tiempo.
2. Escribí `powershell` y presioná **Enter**.
3. Se va a abrir una ventana azul o negra con texto (es normal).

---

### Paso 10 · Ir a la carpeta del proyecto

En la terminal que se abrió, escribí el siguiente comando exactamente como está
y presioná **Enter**:

```
cd "F:\Proyectos\Proyecto de dylan\volleynet"
```

Deberías ver que el texto antes del cursor cambia a:
`PS F:\Proyectos\Proyecto de dylan\volleynet>`

---

### Paso 11 · Lanzar la app en Chrome

Escribí el siguiente comando y presioná **Enter**:

```
F:\flutter\flutter\bin\flutter.bat run -d chrome
```

⏳ La primera vez puede tardar **1 a 2 minutos**. Vas a ver texto que aparece en
la terminal mientras carga. Cuando termine, se va a abrir automáticamente
una ventana de Google Chrome con la app VolleyNet funcionando.

---

### Paso 12 · Crear tu primer usuario

1. En la pantalla que se abrió en Chrome, verás la pantalla de bienvenida de **VolleyNet**.
2. Hacé clic en **"Registrate"**.
3. Elegí tu rol: Jugador, Entrenador o Club.
4. Completá el formulario con tus datos y hacé clic en **"Crear cuenta"**.
5. ¡Listo! Ya podés explorar la app.

---

## PARTE 4 — Distribuir la app (opcional)

Si querés que otras personas accedan a tu app desde internet (sin necesidad de
correrla desde tu computadora), podés subirla a Firebase Hosting.

### Paso A · Compilar la versión final

En la terminal (misma que abriste antes), escribí:

```
F:\flutter\flutter\bin\flutter.bat build web --release
```

Esto crea una carpeta `build\web` con todos los archivos de la app optimizados.

### Paso B · Instalar Firebase Tools

```
npm install -g firebase-tools
```

> ⚠️ Requiere tener Node.js instalado. Descargarlo de [https://nodejs.org](https://nodejs.org)

### Paso C · Iniciar sesión en Firebase desde la terminal

```
firebase login
```

Se va a abrir el navegador para confirmar tu cuenta de Google.

### Paso D · Inicializar Hosting y publicar

```
firebase init hosting
firebase deploy --only hosting
```

Al terminar, Firebase te dará una URL pública tipo `https://volleynet.web.app`
que podés compartir con cualquier persona.

---

## ❓ Solución de problemas frecuentes

| Problema | Solución |
|---|---|
| La terminal dice `flutter no se reconoce` | Cerrá y volvé a abrir la terminal (PowerShell) |
| La app abre pero dice "Error de Firebase" | Revisá que los valores en `main.dart` estén escritos exactamente igual que en Firebase Console |
| La pantalla queda en blanco | Abrí las DevTools de Chrome (F12) → pestaña "Console" y enviá el error que aparece |
| Olvidé mi contraseña de la app | Podés resetear usuarios desde Firebase Console → Authentication → Users |

---

## 📞 Datos del proyecto

| Item | Detalle |
|---|---|
| Proyecto | VolleyNet |
| Ubicación | `F:\Proyectos\Proyecto de dylan\volleynet` |
| Flutter instalado en | `F:\flutter\flutter` |
| Firebase Console | [https://console.firebase.google.com](https://console.firebase.google.com) |

---

*Guía generada automáticamente — VolleyNet v1.0.0*
