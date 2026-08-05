# ⚠️ IMPORTANTE: Activar el APK Build

GitHub bloqueó la subida directa de `.github/workflows/build.yml` por falta de permiso `workflows` en la integración.

## Solución rápida (30 segundos):

1. Ve a tu repo en GitHub web: `Proyectos` -> `Add file` -> `Create new file`
2. Escribe la ruta: `.github/workflows/build.yml`
3. Copia y pega **todo el contenido** de `build.yml` (que está en la raíz, ya está arreglado)
4. Commit directo a `main` o a tu rama `arena/019fd2c7-proyectos`

¡Listo! El próximo push compilará el APK automáticamente en Actions -> Artifacts.

Alternativa: Reconecta GitHub en Arena.ai con permisos de `workflows` y yo lo subiré por ti.

El archivo correcto YA ESTÁ en la raíz como `build.yml` y en `.github/workflows/build.yml` localmente.
