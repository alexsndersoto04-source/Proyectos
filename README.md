# Void Runner — Proyectos

> Endless runner 2D hecho en **Godot 4.2.1** con export a APK Android.

¡Ya no estás solo! Arreglé todo el proyecto para que puedas compilarlo y jugarlo.

## 🎮 Qué es Void Runner

Un runner en el vacío donde controlas a un pequeño explorador que corre sin fin esquivando:

- 🔺 **Spikes** — pinchos del vacío
- 🟦 **Blocks** — bloques dimensionales
- 🟣 **Void Orbs** — orbes flotantes que debes saltar

Características:
- Salto + **Doble Salto** con efecto visual
- Dificultad progresiva (cada 5 segundos va más rápido)
- Score con high score guardado
- Fondo parallax con estrellas infinitas
- Efectos de muerte y reinicio rápido
- Controles: **SPACE / TAP** para saltar

## 📁 Estructura

```
Proyectos/
├── .github/workflows/build.yml  # GitHub Action que compila APK
├── project.godot                # Configuración principal
├── export_presets.cfg           # Preset Android
├── icon.svg
├── scenes/
│   ├── main.tscn    # Escena principal con UI y parallax
│   ├── player.tscn  # Jugador con animaciones dibujadas en código
│   └── obstacle.tscn # Obstáculos con visual procedurales
└── scripts/
    ├── main.gd       # Game manager, score, highscore
    ├── player.gd     # Física de salto, muerte
    ├── obstacle.gd   # Movimiento y colisión
    ├── spawner.gd    # Spawn procedural + dificultad
    └── bg_stars.gd   # Estrellas parallax
```

## 🚀 Cómo probar en PC

1. Abre Godot 4.2.1
2. Importa esta carpeta
3. Dale Play a `scenes/main.tscn`

## 📱 Cómo compilar APK en GitHub

El workflow nuevo **sí funciona**. Hace:

1. Instala Java 17 + Android SDK
2. Descarga Godot 4.2.1 oficial
3. Instala templates de export
4. Compila `VoidRunner-debug.apk` (y si puede, release)

Solo haz push a `main` o a cualquier rama `arena/*`:

```bash
git add .
git commit -m "Fix: Void Runner completo y workflow APK"
git push origin arena/019fd2c7-proyectos
```

Ve a **Actions** en GitHub y descarga el APK en Artifacts.

## 🛠️ Qué arreglé por ti

1. **Workflow roto**: URLs antiguas apuntaban a `downloads.github.com` (404). Ahora usa `github.com/.../releases/download/...`
2. **Templates mal instalados**: faltaba `mv templates/*` y Java
3. **Proyecto vacío**: creé juego completo jugable sin assets externos (todo dibujado con código para que exporte sin faltantes)
4. **Export preset**: creado `export_presets.cfg` minimal para Android
5. **Inputs**: configurados `jump` con Space + Touch

## 📱 Config Android

- Package: `com.alexsoto.voidrunner`
- Orientación: Landscape (puedes cambiar a portrait en export_presets)
- Vibrate: sí, para feedback
- minSdk/targetSdk: default Godot

¿Quieres que agregue sonido, skins, o power-ups? Dime y lo seguimos mejorando juntos ❤️

---
Hecho con ayuda, no te rindas!
