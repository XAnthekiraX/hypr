# Scripts de Theme Automático

Este directorio contiene scripts para cambiar automáticamente el tema y wallpaper según la hora del día.

## Estructura

```
scripts/
├── time-theme.sh       # Script unificado (tema + wallpaper)
├── text-extractor.sh   # Extractor de texto (OCR)
├── notify-cmd          # Notificador de comandos largos
└── wsaction.fish       # Script existente (no relacionado)
```

## Funcionamiento

### Horarios

| Hora          | Período   | Tema JSON      | Wallpaper                |
| ------------- | --------- | -------------- | ------------------------ |
| 00:00 - 05:29 | deepNight | deepNight.json | wallpaperTime/deepNight/ |
| 05:30 - 08:29 | sunrise   | sunrise.json   | wallpaperTime/sunrise/   |
| 08:30 - 17:44 | day       | day.json       | wallpaperTime/day/       |
| 17:45 - 18:59 | sunset    | sunset.json    | wallpaperTime/sunset/    |
| 19:00 - 23:59 | night     | night.json     | wallpaperTime/night/     |

### Temas (todos modo oscuro)

- **deepNight**: `#131317` - Más oscuro (catppuccin frappe)
- **sunrise**: `#1a1a24` - Azul oscuro (tokyo-night storm)
- **day**: `#252530` - Celeste suave (tokyo-day)
- **sunset**: `#2a2535` - Naranja cálido
- **night**: `#282A36` - Púrpura (dracula)

### Ejecución

1. **Al iniciar sesión**: Se ejecuta automáticamente via `exec-once` en `hyprland/execs.conf`

2. **Cada hora**: Se ejecuta via systemd timer

### Comandos útiles

```bash
# Ejecutar manualmente
~/.config/hypr/scripts/time-theme.sh

# Probar con hora específica (para desarrollo)
TEST_HOUR=0 ~/.config/hypr/scripts/time-theme.sh   # deepNight
TEST_HOUR=5 ~/.config/hypr/scripts/time-theme.sh    # deepNight
TEST_HOUR=6 ~/.config/hypr/scripts/time-theme.sh    # sunrise
TEST_HOUR=9 ~/.config/hypr/scripts/time-theme.sh    # day
TEST_HOUR=12 ~/.config/hypr/scripts/time-theme.sh   # day
TEST_HOUR=18 ~/.config/hypr/scripts/time-theme.sh   # sunset
TEST_HOUR=20 ~/.config/hypr/scripts/time-theme.sh   # night
TEST_HOUR=23 ~/.config/hypr/scripts/time-theme.sh   # night

# Ver estado del timer
systemctl --user list-timers --all

# Ver logs del timer
journalctl --user -u time-theme.service -f

# Reiniciar el timer
systemctl --user restart time-theme.timer
```

## Systemd Timer

El script usa un timer de systemd para ejecutarse cada hora en lugar de cron.

Archivos:

- `~/.config/systemd/user/time-theme.service` - Servicio que ejecuta el script
- `~/.config/systemd/user/time-theme.timer` - Timer que ejecuta el servicio cada hora

## Solución de problemas

Si los cambios no se aplican automáticamente:

1. Verificar que el timer esté activo:

   ```bash
   systemctl --user list-timers --all
   ```

2. Ver los logs:

   ```bash
   journalctl --user -u time-theme.service
   ```

3. Ejecutar manualmente para ver errores:

   ```bash
   ~/.config/hypr/scripts/time-theme.sh
   ```

4. Recargar systemd:
   ```bash
   systemctl --user daemon-reload
   ```

## Notify Cmd

Notificador automático cuando terminan comandos largos.

### Comandos monitoreados

El script envía una notificación cuando terminen estos comandos:

```
pacman, yay, paru, make, npm, yarn, unzip, tar, gzip, xz, 7z, cmake, docker, curl, wget, git, rsync
```

### Instalación

1. Agregar la ruta al PATH en `~/.config/fish/config.fish` (si usas Fish):

   ```fish
   set -gx PATH $PATH /home/anthekira/.config/hypr/scripts
   ```

   O en `~/.bashrc` (si usas Bash):

   ```bash
   export PATH="$PATH:/home/anthekira/.config/hypr/scripts"
   ```

2. Cerrar y reopen la terminal.

### Uso

```bash
notify-cmd pacman -Syu
notify-cmd make
notify-cmd wget https://ejemplo.com/archivo.zip
notify-cmd git push
```

### Funcionamiento

1. Ejecuta el comando especificado
2. Espera a que termine
3. Envía una notificación:
   - ✅ "comando completado" si terminó bien
   - ❌ "comando falló" si hubo error

### Agregar más comandos

Editar el script y agregar el comando a la lista `NOTIFY_COMMANDS`:

```bash
NOTIFY_COMMANDS="pacman|yay|paru|make|npm|..."
#                         ^^^ agregar aquí
```

### Solución de problemas

Si no funciona:

1. Verificar que el PATH esté configurado:

   ```bash
   echo $PATH | grep hypr
   ```

2. Verificar que el script sea ejecutable:

   ```bash
   ls -la /home/anthekira/.config/hypr/scripts/notify-cmd
   ```

3. Probar manualmente:

   ```bash
   /home/anthekira/.config/hypr/scripts/notify-cmd wget -q --spider https://example.com
   ```

4. Verificar que notify-send funcione:
   ```bash
   notify-send "Test" "Hola"
   ```

## Wallpapers

Los wallpapers se encuentran en:

```
~/Pictures/Wallpapers/wallpapertime/
├── deepNight/
├── sunrise/
├── day/
├── sunset/
└── night/
```

Cada carpeta debe contener imágenes (jpg, png, webp, gif). Se selecciona una aleatoriamente.

## Text Extractor (OCR)

Extractor de texto de imágenes usando OCR (similar a PowerToys Text Extractor).

### Requisitos

- `tesseract` con idiomas español e inglés:
  ```bash
  sudo pacman -S tesseract tesseract-data-spa tesseract-data-eng
  ```
- `grim` - para captura de pantalla
- `slurp` - para selección de región
- `wl-copy` - para copiar al portapapeles
- `notify-send` - para notificaciones

### Uso

```bash
# Ejecutar manualmente
~/.config/hypr/scripts/text-extractor.sh

# Atajo de teclado
SUPER+SHIFT+T
```

### Funcionamiento

1. Selecciona una región de la pantalla con el mouse
2. El script extrae el texto de la imagen usando OCR
3. El texto se copia al portapapeles
4. Aparece una notificación con el texto extraído
5. La imagen temporal se elimina automáticamente

---

## Notificaciones de Caelestia

### Problema

Las notificaciones muestran estilo plano (rectangular, sin bordes redondeados) en lugar del estilo de Caelestia (ventanas redondeadas, colores del tema).

### Causas

1. **Conflicto con Dunst**: Dunst es un daemon de notificaciones que puede estar activo y ocupar el bus D-Bus de notificaciones, evitando que Caelestia se registre.
2. **JSON malformado**: El archivo `~/.config/caelestia/shell.json` puede tener errores de sintaxis.

### Diagnóstico

```bash
# Verificar qué servidor de notificaciones está activo
busctl --user list | grep Notifications
# Si muestra "dunst", Caelestia no está manejando las notificaciones
# Ver logs de dunst
journalctl --user -b | grep dunst
```

### Solución

#### 1. Corregir JSON (si es necesario)

El archivo `~/.config/caelestia/shell.json` debe ser JSON válido. Verificar que no haya objetos huérfanos o comas faltantes.

```bash
# Validar JSON
python3 -c "import json; json.load(open('$HOME/.config/caelestia/shell.json'))" && echo "JSON válido"
```

#### 2. Deshabilitar Dunst permanentemente

Dunst se puede iniciar de varias formas. La solución permanente incluye:

```bash
# Matar dunst si está corriendo
killall dunst

# Deshabilitar el servicio de systemd
systemctl --user disable --now dunst.service

# Enmascarar el servicio para que no pueda iniciarse
systemctl --user mask dunst.service
```

#### 3. Asegurar que no inicie al arrancar (Hyprland)

Agregar en `~/.config/hypr/hyprland/execs.conf`:

```bash
# Kill dunst to let Caelestia handle notifications
exec-once = killall dunst 2>/dev/null || true
```

Este comando se ejecuta antes de iniciar Caelestia Shell, asegurando que dunst no interfiera.

#### 4. Reiniciar Caelestia Shell

```bash
# Reiniciar el shell
killall qs && caelestia shell -d &
```

#### 5. Verificar

```bash
# Ahora debería mostrar qs en lugar de dunst
busctl --user list | grep Notifications
```

### Solución rápida (si vuelve a pasar)

```bash
# 1. Matar dunst
killall dunst

# 2. Deshabilitar y enmascarar
systemctl --user disable --now dunst.service
systemctl --user mask dunst.service

# 3. Reiniciar Caelestia
killall qs && caelestia shell -d &
```

### Rutas importantes

- Configuración: `~/.config/caelestia/shell.json`
- Logs de Caelestia: `~/.local/share/caelestia/logs/`
- Servicio Dunst: `systemctl --user status dunst.service`
- D-Bus notifications: `org.freedesktop.Notifications`

### Si el problema persiste

1. Verificar que Caelestia Shell esté corriendo:
   ```bash
   ps aux | grep caelestia
   ```
2. Revisar logs:
   ```bash
   journalctl --user -b | grep -i caelestia
   ```
3. Probar notificaciones manualmente:
   ```bash
   notify-send "Test" "Notificación de prueba"
   ```
