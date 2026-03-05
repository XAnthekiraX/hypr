# Scripts de Theme Automático

Este directorio contiene scripts para cambiar automáticamente el tema y wallpaper según la hora del día.

## Estructura

```
scripts/
├── time-theme.sh       # Script unificado (tema + wallpaper)
└── wsaction.fish       # Script existente (no relacionado)
```

## Funcionamiento

### Horarios

| Hora           | Período     | Tema JSON         | Wallpaper               |
|----------------|-------------|-------------------|------------------------|
| 00:00 - 05:29 | deepNight   | deepNight.json    | wallpaperTime/deepNight/ |
| 05:30 - 08:29 | sunrise     | sunrise.json      | wallpaperTime/sunrise/ |
| 08:30 - 17:44 | day         | day.json          | wallpaperTime/day/ |
| 17:45 - 18:59 | sunset      | sunset.json       | wallpaperTime/sunset/ |
| 19:00 - 23:59 | night       | night.json        | wallpaperTime/night/ |

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
