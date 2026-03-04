# Scripts de Theme Automático

Este directorio contiene scripts para cambiar automáticamente el tema y wallpaper según la hora del día.

## Estructura

```
scripts/
├── theme-switch.sh       # Cambia el tema de Caelestia
├── wallpaper-select.sh   # Selecciona un wallpaper aleatorio
├── time-based-theme.sh   # Script principal que detecta hora y aplica cambios
└── wsaction.fish         # Script existente (no relacionado)
```

## Funcionamiento

### Horarios

| Hora           | Período     | Tema JSON          | Wallpaper            |
|----------------|-------------|--------------------|----------------------|
| 06:00 - 11:59  | morning     | morning.json       | wallpaperTime/morning/ |
| 12:00 - 17:59  | afternoon   | afternoon.json     | wallpaperTime/afternoon/ |
| 18:00 - 23:59  | night       | night.json         | wallpaperTime/night/ |
| 00:00 - 05:59  | deepnight   | deepnight.json     | wallpaperTime/deepnight/ |

### Ejecución

1. **Al iniciar sesión**: Se ejecuta automáticamente via `exec-once` en `hyprland/execs.conf`

2. **Cada hora**: Se ejecuta via systemd timer

### Comandos útiles

```bash
# Ejecutar manualmente
~/.config/hypr/scripts/time-based-theme.sh

# Probar con hora específica (para desarrollo)
TEST_HOUR=7 ~/.config/hypr/scripts/time-based-theme.sh   # morning
TEST_HOUR=14 ~/.config/hypr/scripts/time-based-theme.sh  # afternoon
TEST_HOUR=20 ~/.config/hypr/scripts/time-based-theme.sh  # night
TEST_HOUR=3 ~/.config/hypr/scripts/time-based-theme.sh   # deepnight

# Ver estado del timer
systemctl --user list-timers --all

# Ver logs del timer
journalctl --user -u time-based-theme.service -f

# Reiniciar el timer
systemctl --user restart time-based-theme.timer
```

## Systemd Timer

El script usa un timer de systemd para ejecutarse cada hora en lugar de cron.

Archivos:
- `~/.config/systemd/user/time-based-theme.service` - Servicio que ejecuta el script
- `~/.config/systemd/user/time-based-theme.timer` - Timer que ejecuta el servicio cada hora

## Solución de problemas

Si los cambios no se aplican automáticamente:

1. Verificar que el timer esté activo:
   ```bash
   systemctl --user list-timers --all
   ```

2. Ver los logs:
   ```bash
   journalctl --user -u time-based-theme.service
   ```

3. Ejecutar manualmente para ver errores:
   ```bash
   ~/.config/hypr/scripts/time-based-theme.sh
   ```

4. Recargar systemd:
   ```bash
   systemctl --user daemon-reload
   ```
