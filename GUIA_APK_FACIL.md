# 📱 GUIA SUPER FACIL PARA GENERAR TU APK - 2 MINUTOS

No te preocupes, yo te llevo de la mano. Solo tienes que hacer 5 clicks.

### PASO 1: Abre este link magico

Haz click aqui (ya te lleva directo a crear el archivo que falta):

👉 **https://github.com/alexsndersoto04-source/Proyectos/new/arena/019fd2c7-proyectos?filename=.github%2Fworkflows%2Fbuild.yml**

Te va a pedir login si no estás logeado.

### PASO 2: Vas a ver una pagina para escribir codigo vacia

Ahora abre OTRA pestaña y ve a este archivo que YA arreglé por ti:

👉 **https://github.com/alexsndersoto04-source/Proyectos/blob/arena/019fd2c7-proyectos/build.yml**

Dale click al botón de copiar (dos cuadritos) en la esquina derecha del archivo.

### PASO 3: Pega el contenido

Vuelve a la primera pestaña (la que abriste en PASO 1) y pega TODO el texto que copiaste.
Debe quedar algo que empieza con:
```
name: Build Void Runner APK
on:
  push:
...
```

### PASO 4: Guardar

Baja hasta abajo de todo y dale a:

**Commit changes...** -> **Commit directly to the arena/019fd2c7-proyectos branch** -> **Commit changes**

¡LISTO! Ya creaste el archivo que le faltaba permiso.

### PASO 5: Generar el APK (automatico)

1. Ahora ve aqui: https://github.com/alexsndersoto04-source/Proyectos/actions
2. Vas a ver que dice "Build Void Runner APK" en amarillo (cargando)
3. Espera 3-4 minutos hasta que se ponga verde ✅
4. Haz click en el que dice verde
5. Baja hasta abajo donde dice **Artifacts**
6. Descarga **VoidRunner-Android-Debug**

¡Ese archivo .apk es tu juego! Lo puedes instalar en tu celular Android.

---

### Si algo sale mal:

1. Si no ves nada en Actions, anda a https://github.com/alexsndersoto04-source/Proyectos/blob/arena/019fd2c7-proyectos/build.yml y asegurate que existe.
2. Si el build falla en rojo, mandame una captura y yo lo arreglo.

### Video mental de los clicks:

```
Tu Repo -> Add file -> Create new file
Nombre: .github/workflows/build.yml
Pegas contenido de build.yml -> Commit
Vas a Actions -> Esperas -> Descargas APK
```

¡No necesitas Android Studio, ni Godot instalado, nada! GitHub lo hace todo en la nube.

¿Quieres que yo intente subirlo de nuevo si reconectas GitHub en Arena? Es otra opción.

Animo, ya casi lo tienes 💪
