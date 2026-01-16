#!/bin/bash

# Script de menú principal para gestión de notificaciones push
# Facilita el acceso a todas las herramientas de prueba

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Función para mostrar el header
show_header() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}🔔 Herramientas de Notificaciones Push${NC}                  ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}📱 SUAyED Psicología FES Iztacala${NC}                      ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Función para mostrar el menú
show_menu() {
    echo -e "${YELLOW}Selecciona una opción:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} 🔑 Obtener token FCM del dispositivo"
    echo -e "  ${GREEN}2)${NC} 📤 Enviar notificación a dispositivo específico"
    echo -e "  ${GREEN}3)${NC} 📢 Enviar notificación a tópico (posts/alerts)"
    echo -e "  ${GREEN}4)${NC} 🧪 Ejecutar suite de pruebas automatizadas"
    echo -e "  ${GREEN}5)${NC} ⚙️  Configurar credenciales (editar config.sh)"
    echo -e "  ${GREEN}6)${NC} 📖 Ver documentación"
    echo -e "  ${GREEN}7)${NC} 📊 Ver estado de configuración"
    echo -e "  ${GREEN}0)${NC} 🚪 Salir"
    echo ""
}

# Función para verificar configuración
check_config() {
    if [ -f "config.sh" ]; then
        source config.sh

        CONFIG_OK=true

        if [ -z "$FCM_SERVER_KEY" ] || [ "$FCM_SERVER_KEY" = "YOUR_FIREBASE_SERVER_KEY" ]; then
            echo -e "${RED}❌ Server Key no configurado${NC}"
            CONFIG_OK=false
        else
            echo -e "${GREEN}✅ Server Key configurado${NC}"
        fi

        if [ -z "$FCM_DEVICE_TOKEN" ] || [ "$FCM_DEVICE_TOKEN" = "YOUR_DEVICE_FCM_TOKEN" ]; then
            echo -e "${RED}❌ Device Token no configurado${NC}"
            CONFIG_OK=false
        else
            echo -e "${GREEN}✅ Device Token configurado${NC}"
        fi

        if [ "$CONFIG_OK" = false ]; then
            echo ""
            echo -e "${YELLOW}💡 Configura tus credenciales:${NC}"
            echo -e "   ${BLUE}Opción 5) Configurar credenciales${NC}"
            echo -e "   ${BLUE}O edita manualmente: nano config.sh${NC}"
        fi

        return 0
    else
        echo -e "${YELLOW}⚠️  Archivo config.sh no encontrado${NC}"
        echo ""
        echo -e "${YELLOW}¿Deseas crearlo ahora? (s/n):${NC} "
        read -r CREATE_CONFIG

        if [ "$CREATE_CONFIG" = "s" ] || [ "$CREATE_CONFIG" = "S" ]; then
            cp config.example.sh config.sh
            echo -e "${GREEN}✅ config.sh creado${NC}"
            echo -e "${YELLOW}💡 Edítalo para agregar tus credenciales (Opción 5)${NC}"
        fi

        return 1
    fi
}

# Función para obtener token
get_token() {
    show_header
    echo -e "${CYAN}🔑 Obteniendo token FCM...${NC}"
    echo ""

    cd ../.. || exit  # Ir al directorio raíz del proyecto
    ./scripts/notifications/get_token.sh
    cd scripts/notifications || exit

    echo ""
    read -p "Presiona ENTER para continuar..."
}

# Función para enviar notificación a dispositivo
send_to_device() {
    show_header
    echo -e "${CYAN}📤 Enviar notificación a dispositivo${NC}"
    echo ""

    if ! check_config; then
        echo ""
        read -p "Presiona ENTER para continuar..."
        return
    fi

    source config.sh

    # Modificar temporalmente los scripts para usar las variables de entorno
    export SERVER_KEY="$FCM_SERVER_KEY"
    export DEVICE_TOKEN="$FCM_DEVICE_TOKEN"

    ./send_notification.sh

    echo ""
    read -p "Presiona ENTER para continuar..."
}

# Función para enviar a tópico
send_to_topic() {
    show_header
    echo -e "${CYAN}📢 Enviar notificación a tópico${NC}"
    echo ""

    if ! check_config; then
        echo ""
        read -p "Presiona ENTER para continuar..."
        return
    fi

    source config.sh
    export SERVER_KEY="$FCM_SERVER_KEY"

    ./send_to_topic.sh

    echo ""
    read -p "Presiona ENTER para continuar..."
}

# Función para ejecutar pruebas
run_tests() {
    show_header
    echo -e "${CYAN}🧪 Suite de pruebas automatizadas${NC}"
    echo ""

    if ! check_config; then
        echo ""
        read -p "Presiona ENTER para continuar..."
        return
    fi

    echo -e "${YELLOW}Configuración de pruebas:${NC}"
    echo ""
    echo -e "  1) Ejecutar todos los casos (delay 5s)"
    echo -e "  2) Ejecutar todos los casos (delay personalizado)"
    echo -e "  3) Ejecutar casos específicos"
    echo -e "  0) Volver"
    echo ""
    read -p "Opción: " TEST_OPTION

    case $TEST_OPTION in
        1)
            python3 test_notifications.py
            ;;
        2)
            read -p "Delay en segundos: " DELAY
            python3 test_notifications.py --delay "$DELAY"
            ;;
        3)
            read -p "Casos a ejecutar (ej: 1,2,3): " CASES
            read -p "Delay en segundos (default 5): " DELAY
            DELAY=${DELAY:-5}
            python3 test_notifications.py --cases "$CASES" --delay "$DELAY"
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Opción inválida${NC}"
            ;;
    esac

    echo ""
    read -p "Presiona ENTER para continuar..."
}

# Función para configurar credenciales
configure() {
    show_header
    echo -e "${CYAN}⚙️  Configurar credenciales${NC}"
    echo ""

    if [ ! -f "config.sh" ]; then
        cp config.example.sh config.sh
        echo -e "${GREEN}✅ Archivo config.sh creado${NC}"
        echo ""
    fi

    echo -e "${YELLOW}Abriendo editor...${NC}"
    echo ""

    # Intentar usar diferentes editores
    if command -v nano &> /dev/null; then
        nano config.sh
    elif command -v vim &> /dev/null; then
        vim config.sh
    elif command -v vi &> /dev/null; then
        vi config.sh
    else
        echo -e "${RED}❌ No se encontró un editor de texto${NC}"
        echo -e "${YELLOW}Edita manualmente: nano config.sh${NC}"
    fi

    echo ""
    echo -e "${GREEN}✅ Configuración guardada${NC}"
    echo ""
    read -p "Presiona ENTER para continuar..."
}

# Función para ver documentación
view_docs() {
    show_header
    echo -e "${CYAN}📖 Documentación${NC}"
    echo ""

    if command -v less &> /dev/null; then
        less README.md
    elif command -v more &> /dev/null; then
        more README.md
    else
        cat README.md
    fi

    echo ""
    read -p "Presiona ENTER para continuar..."
}

# Función para ver estado
show_status() {
    show_header
    echo -e "${CYAN}📊 Estado de configuración${NC}"
    echo ""

    # Verificar config.sh
    if [ -f "config.sh" ]; then
        echo -e "${GREEN}✅ Archivo config.sh existe${NC}"
        source config.sh

        echo ""
        echo -e "${YELLOW}Credenciales:${NC}"

        if [ -n "$FCM_SERVER_KEY" ] && [ "$FCM_SERVER_KEY" != "YOUR_FIREBASE_SERVER_KEY" ]; then
            echo -e "  ${GREEN}✅${NC} Server Key: ${FCM_SERVER_KEY:0:20}..."
        else
            echo -e "  ${RED}❌${NC} Server Key: No configurado"
        fi

        if [ -n "$FCM_DEVICE_TOKEN" ] && [ "$FCM_DEVICE_TOKEN" != "YOUR_DEVICE_FCM_TOKEN" ]; then
            echo -e "  ${GREEN}✅${NC} Device Token: ${FCM_DEVICE_TOKEN:0:20}..."
        else
            echo -e "  ${RED}❌${NC} Device Token: No configurado"
        fi
    else
        echo -e "${RED}❌ Archivo config.sh no existe${NC}"
    fi

    echo ""
    echo -e "${YELLOW}Scripts disponibles:${NC}"

    for script in send_notification.sh send_to_topic.sh test_notifications.py get_token.sh; do
        if [ -x "$script" ]; then
            echo -e "  ${GREEN}✅${NC} $script (ejecutable)"
        elif [ -f "$script" ]; then
            echo -e "  ${YELLOW}⚠️${NC}  $script (existe pero no es ejecutable)"
        else
            echo -e "  ${RED}❌${NC} $script (no encontrado)"
        fi
    done

    echo ""
    echo -e "${YELLOW}Dependencias:${NC}"

    # Verificar curl
    if command -v curl &> /dev/null; then
        echo -e "  ${GREEN}✅${NC} curl $(curl --version | head -1)"
    else
        echo -e "  ${RED}❌${NC} curl (no instalado)"
    fi

    # Verificar python3
    if command -v python3 &> /dev/null; then
        echo -e "  ${GREEN}✅${NC} python3 $(python3 --version)"
    else
        echo -e "  ${RED}❌${NC} python3 (no instalado)"
    fi

    # Verificar requests
    if python3 -c "import requests" 2>/dev/null; then
        echo -e "  ${GREEN}✅${NC} requests (módulo Python instalado)"
    else
        echo -e "  ${RED}❌${NC} requests (módulo Python no instalado)"
        echo -e "     ${YELLOW}Instalar: pip3 install requests${NC}"
    fi

    # Verificar Flutter
    if command -v flutter &> /dev/null; then
        echo -e "  ${GREEN}✅${NC} flutter $(flutter --version | head -1)"
    else
        echo -e "  ${YELLOW}⚠️${NC}  flutter (no encontrado en PATH)"
    fi

    echo ""
    read -p "Presiona ENTER para continuar..."
}

# Función principal
main() {
    # Cambiar al directorio del script
    cd "$(dirname "$0")" || exit

    while true; do
        show_header
        show_menu

        read -p "Opción: " option

        case $option in
            1) get_token ;;
            2) send_to_device ;;
            3) send_to_topic ;;
            4) run_tests ;;
            5) configure ;;
            6) view_docs ;;
            7) show_status ;;
            0)
                echo ""
                echo -e "${GREEN}👋 ¡Hasta luego!${NC}"
                echo ""
                exit 0
                ;;
            *)
                echo ""
                echo -e "${RED}❌ Opción inválida${NC}"
                sleep 1
                ;;
        esac
    done
}

# Ejecutar
main
