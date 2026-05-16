#!/usr/bin/env bash
# sulfurde installer — curl https://sulfurde.vercel.app | bash

set -e

# colores
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; W='\033[1;37m'; D='\033[0;90m'; N='\033[0m'

clear
echo -e "${G}"
cat << 'BANNER'
 ███████╗██╗   ██╗██╗     ███████╗██╗   ██╗██████╗ ██████╗ ███████╗
 ██╔════╝██║   ██║██║     ██╔════╝██║   ██║██╔══██╗██╔══██╗██╔════╝
 ███████╗██║   ██║██║     █████╗  ██║   ██║██████╔╝██║  ██║█████╗
 ╚════██║██║   ██║██║     ██╔══╝  ██║   ██║██╔══██╗██║  ██║██╔══╝
 ███████║╚██████╔╝███████╗██║     ╚██████╔╝██║  ██║██████╔╝███████╗
 ╚══════╝ ╚═════╝ ╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝
BANNER
echo -e "${D}  i3 · xorg · ultraligero · ~50MB RAM${N}"
echo ""

ask() { echo -e "${C}?${N} ${W}$1${N} ${D}$2${N}"; }
ok()  { echo -e "${G}✓${N} $1"; }
err() { echo -e "${R}✗${N} $1"; }
sep() { echo -e "${D}──────────────────────────────────────${N}"; }

# ── 1. DISTRO ──────────────────────────────────────────────────────
sep
echo -e "${W}[1/5] Distribución${N}"
echo ""
echo -e "  ${C}1${N}) Debian / Ubuntu / Mint"
echo -e "  ${C}2${N}) Arch / Manjaro"
echo -e "  ${C}3${N}) Fedora / RHEL / CentOS"
echo -e "  ${C}4${N}) Void Linux"
echo ""
ask "Selecciona tu distro:" "[1-4]"
read -rp "  > " DISTRO_OPT

case $DISTRO_OPT in
  1) DISTRO="debian"
     PKG_CMD="sudo apt install -y"
     PKGS="xorg xinit i3 i3status dmenu st dunst alsa-utils network-manager" ;;
  2) DISTRO="arch"
     PKG_CMD="sudo pacman -S --noconfirm"
     PKGS="xorg-server xorg-xinit i3-wm i3status dmenu st dunst alsa-utils networkmanager" ;;
  3) DISTRO="fedora"
     PKG_CMD="sudo dnf install -y"
     PKGS="xorg-x11-server-Xorg xorg-x11-xinit i3 i3status dmenu st dunst alsa-utils NetworkManager" ;;
  4) DISTRO="void"
     PKG_CMD="sudo xbps-install -y"
     PKGS="xorg-server xinit i3 i3status dmenu st dunst alsa-utils NetworkManager" ;;
  *) err "Opción inválida"; exit 1 ;;
esac
ok "Distro: $DISTRO"

# ── 2. COMPONENTES ────────────────────────────────────────────────
sep
echo -e "${W}[2/5] Componentes a instalar${N}"
echo ""
echo -e "  ${C}a${N}) Todo (recomendado)                ~50 MB RAM"
echo -e "  ${C}b${N}) Mínimo absoluto                   ~35 MB RAM"
echo -e "      ${D}(xorg + i3 + dmenu + st — sin dunst ni audio)${N}"
echo -e "  ${C}c${N}) Personalizado"
echo ""
ask "¿Qué instalar?" "[a/b/c]"
read -rp "  > " COMP_OPT

INSTALL_DUNST=true
INSTALL_AUDIO=true
INSTALL_NET=true

case $COMP_OPT in
  a|A) ok "Instalación completa seleccionada" ;;
  b|B)
    INSTALL_DUNST=false
    INSTALL_AUDIO=false
    PKGS=$(echo "$PKGS" | sed 's/dunst//;s/alsa-utils//')
    ok "Instalación mínima seleccionada" ;;
  c|C)
    echo ""
    read -rp "  ¿Instalar dunst (notificaciones)? [s/N] " R_DUNST
    read -rp "  ¿Instalar alsa (audio)?           [s/N] " R_AUDIO
    read -rp "  ¿Instalar networkmanager?         [S/n] " R_NET
    [[ "$R_DUNST" =~ ^[sS]$ ]] || { INSTALL_DUNST=false; PKGS=$(echo "$PKGS" | sed 's/dunst//'); }
    [[ "$R_AUDIO" =~ ^[sS]$ ]] || { INSTALL_AUDIO=false; PKGS=$(echo "$PKGS" | sed 's/alsa-utils//'); }
    [[ "$R_NET"   =~ ^[nN]$ ]] && { INSTALL_NET=false;   PKGS=$(echo "$PKGS" | sed 's/network-manager//;s/networkmanager//;s/NetworkManager//'); }
    ok "Personalización aplicada" ;;
  *) err "Opción inválida"; exit 1 ;;
esac

# ── 3. ARRANQUE ───────────────────────────────────────────────────
sep
echo -e "${W}[3/5] Arranque de sesión${N}"
echo ""
echo -e "  ${C}1${N}) startx automático al login en tty1  ${D}(recomendado — 0 MB extra)${N}"
echo -e "  ${C}2${N}) LightDM display manager              ${D}(pantalla de login gráfica ~20 MB)${N}"
echo -e "  ${C}3${N}) Solo configurar, yo arranco a mano"
echo ""
ask "¿Cómo arrancar el escritorio?" "[1-3]"
read -rp "  > " BOOT_OPT

case $BOOT_OPT in
  1) BOOT="startx" ;;
  2) BOOT="lightdm"
     PKGS="$PKGS lightdm lightdm-gtk-greeter" ;;
  3) BOOT="manual" ;;
  *) err "Opción inválida"; exit 1 ;;
esac
ok "Arranque: $BOOT"

# ── 4. RESUMEN ────────────────────────────────────────────────────
sep
echo -e "${W}[4/5] Resumen — confirmar instalación${N}"
echo ""
echo -e "  Distro   : ${C}$DISTRO${N}"
echo -e "  Paquetes : ${C}$(echo $PKGS | tr -s ' ')${N}"
echo -e "  Arranque : ${C}$BOOT${N}"
echo -e "  Dunst    : ${C}$INSTALL_DUNST${N}"
echo -e "  Audio    : ${C}$INSTALL_AUDIO${N}"
echo -e "  Red      : ${C}$INSTALL_NET${N}"
echo ""
ask "¿Continuar con la instalación?" "[s/N]"
read -rp "  > " CONFIRM
[[ "$CONFIRM" =~ ^[sS]$ ]] || { echo -e "${D}Cancelado.${N}"; exit 0; }

# ── 5. INSTALAR ───────────────────────────────────────────────────
sep
echo -e "${W}[5/5] Instalando...${N}"
echo ""

echo -e "${D}>> paquetes...${N}"
$PKG_CMD $PKGS

echo -e "${D}>> directorios de config...${N}"
mkdir -p ~/.config/i3 ~/.config/i3status ~/.config/dunst

echo -e "${D}>> ~/.xinitrc...${N}"
cat > ~/.xinitrc << 'XINITRC'
#!/bin/sh
xsetroot -solid black &
dunst &
exec i3
XINITRC
chmod +x ~/.xinitrc

echo -e "${D}>> ~/.config/i3/config...${N}"
cat > ~/.config/i3/config << 'I3CONF'
set $mod Mod4
font pango:monospace 9
bindsym $mod+Return exec st
bindsym $mod+d exec dmenu_run
bindsym $mod+Shift+q kill
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+f fullscreen toggle
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5
bindsym $mod+Shift+r restart
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec i3-msg exit
floating_modifier $mod
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle
mode "resize" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"
bar {
    status_command i3status
    position top
    colors {
        background #0d0f0e
        statusline #c8d4c8
        focused_workspace  #4afa7a #4afa7a #0d0f0e
        inactive_workspace #0d0f0e #0d0f0e #4a5248
    }
}
client.focused          #4afa7a #0d0f0e #c8d4c8 #4afa7a #4afa7a
client.unfocused        #2a2e2a #0d0f0e #4a5248 #2a2e2a #2a2e2a
I3CONF

echo -e "${D}>> ~/.config/i3status/config...${N}"
cat > ~/.config/i3status/config << 'I3STATUS'
general {
    colors = true
    interval = 5
    color_good = "#4afa7a"
    color_degraded = "#faad4a"
    color_bad = "#fa4a4a"
}
order += "disk /"
order += "memory"
order += "cpu_usage"
order += "wireless _first_"
order += "ethernet _first_"
order += "tztime local"
disk "/" { format = "disk: %avail" }
memory { format = "ram: %used/%total" threshold_degraded = "10%" }
cpu_usage { format = "cpu: %usage" }
wireless _first_ { format_up = "wifi: %essid" format_down = "wifi: --" }
ethernet _first_ { format_up = "eth: up" format_down = "eth: --" }
tztime local { format = "%H:%M %d/%m" }
I3STATUS

if $INSTALL_DUNST; then
  echo -e "${D}>> ~/.config/dunst/dunstrc...${N}"
  cat > ~/.config/dunst/dunstrc << 'DUNSTRC'
[global]
    geometry = "300x5-10+30"
    font = monospace 9
    frame_width = 1
    frame_color = "#2a2e2a"
    format = "%s\n%b"
[urgency_low]
    background = "#0d0f0e"
    foreground = "#4a5248"
    timeout = 4
[urgency_normal]
    background = "#0d0f0e"
    foreground = "#c8d4c8"
    timeout = 6
[urgency_critical]
    background = "#0d0f0e"
    foreground = "#fa4a4a"
    frame_color = "#fa4a4a"
    timeout = 0
DUNSTRC
fi

if [ "$BOOT" = "startx" ]; then
  echo -e "${D}>> startx automático en ~/.bash_profile...${N}"
  grep -q "startx" ~/.bash_profile 2>/dev/null || cat >> ~/.bash_profile << 'BPROFILE'

# auto startx en tty1
[ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ] && exec startx
BPROFILE
fi

if [ "$BOOT" = "lightdm" ] && [ "$DISTRO" = "arch" ]; then
  sudo systemctl enable lightdm
fi

if $INSTALL_NET && [ "$DISTRO" = "arch" ]; then
  sudo systemctl enable NetworkManager
fi

# ── DONE ──────────────────────────────────────────────────────────
echo ""
sep
echo -e "${G}  ✓ Instalación completa${N}"
echo ""
echo -e "  ${W}Atajos i3:${N}"
echo -e "  ${C}Mod+Enter${N}   terminal"
echo -e "  ${C}Mod+d${N}       lanzar apps"
echo -e "  ${C}Mod+1..5${N}    workspaces"
echo -e "  ${C}Mod+Shift+q${N} cerrar ventana"
echo -e "  ${C}Mod+Shift+r${N} recargar i3"
echo ""
if [ "$BOOT" = "startx" ]; then
  echo -e "  ${D}Reinicia y loguea en tty1 — X arranca solo.${N}"
elif [ "$BOOT" = "lightdm" ]; then
  echo -e "  ${D}Reinicia — LightDM arrancará la sesión.${N}"
else
  echo -e "  ${D}Ejecuta 'startx' para iniciar el escritorio.${N}"
fi
echo ""
sep
