# Fix para Dolphin en Hyprland (Arch Linux)

## Problema
Dolphin no abre imágenes/videos por defecto y siempre pregunta qué aplicación usar.

## Causa
Falta el archivo `applications.menu` y la variable de entorno `XDG_MENU_PREFIX` no está configurada.

## Solución

### 1. Instalar paquete necesario
```bash
sudo pacman -S archlinux-xdg-menu
```

### 2. Configuración persistente en Hyprland

En `~/.config/hypr/hyprland.conf`, ya están agregadas las siguientes líneas:

```ini
# XDG Menu fix para Dolphin
env = XDG_MENU_PREFIX,arch-
exec-once = kbuildsycoca6 --noincremental
```

### 3. Configurar aplicaciones por defecto

```bash
# Imágenes
xdg-mime default imv.desktop image/png image/jpeg image/gif image/webp

# Videos
xdg-mime default vlc.desktop video/mp4 video/x-matroska video/webm

# Audio
xdg-mime default vlc.desktop audio/mpeg audio/flac audio/wav
```

### 4. Alternativa: Configurar desde Dolphin (GUI)
1. Click derecho en archivo → Propiedades → Opciones de tipo de archivo
2. Seleccionar app → Mover arriba → Aceptar

## Verificación
```bash
xdg-mime query default image/png
xdg-mime query default video/mp4
```

## Después de actualizar KDE/Plasma
Es posible que necesiten ejecutar:
```bash
XDG_MENU_PREFIX=arch- kbuildsycoca6 --noincremental
```
