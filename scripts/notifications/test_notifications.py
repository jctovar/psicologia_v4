#!/usr/bin/env python3
"""
Script de pruebas automatizadas para notificaciones push
Envía múltiples notificaciones de diferentes tipos con delays configurables

Uso:
    python3 test_notifications.py
    python3 test_notifications.py --delay 10
    python3 test_notifications.py --cases 1,2,3
"""

import requests
import json
import time
import argparse
from datetime import datetime
from typing import Dict, List

# Colores para terminal
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

# Configuración - REEMPLAZAR CON TUS VALORES
SERVER_KEY = "YOUR_FIREBASE_SERVER_KEY"
DEVICE_TOKEN = "YOUR_DEVICE_FCM_TOKEN"
FCM_URL = "https://fcm.googleapis.com/fcm/send"

def validate_config():
    """Valida que las credenciales estén configuradas"""
    if SERVER_KEY == "YOUR_FIREBASE_SERVER_KEY":
        print(f"{Colors.RED}❌ Error: Debes configurar el SERVER_KEY{Colors.ENDC}")
        print(f"{Colors.YELLOW}   Edita el archivo y reemplaza SERVER_KEY con tu clave de Firebase{Colors.ENDC}")
        return False

    if DEVICE_TOKEN == "YOUR_DEVICE_FCM_TOKEN":
        print(f"{Colors.RED}❌ Error: Debes configurar el DEVICE_TOKEN{Colors.ENDC}")
        print(f"{Colors.YELLOW}   Edita el archivo y reemplaza DEVICE_TOKEN con el token de tu dispositivo{Colors.ENDC}")
        return False

    return True

def get_test_cases() -> List[Dict]:
    """Define los casos de prueba"""
    timestamp = datetime.utcnow().isoformat() + "Z"

    return [
        {
            "id": 1,
            "name": "📰 Post nuevo",
            "description": "Notificación de publicación nueva",
            "payload": {
                "to": DEVICE_TOKEN,
                "notification": {
                    "title": "📰 Nueva publicación",
                    "body": "Se ha publicado contenido nuevo en el portal SUAyED"
                },
                "data": {
                    "type": "post",
                    "post_id": "12345",
                    "category": "noticias",
                    "test": "true",
                    "timestamp": timestamp
                },
                "priority": "high"
            }
        },
        {
            "id": 2,
            "name": "📅 Evento calendario",
            "description": "Recordatorio de evento del calendario escolar",
            "payload": {
                "to": DEVICE_TOKEN,
                "notification": {
                    "title": "📅 Recordatorio de evento",
                    "body": "Los exámenes finales comienzan el próximo lunes"
                },
                "data": {
                    "type": "calendar_event",
                    "event_id": "exam_final_2025_1",
                    "event_type": "Examenes",
                    "start_date": "2025-01-20",
                    "test": "true",
                    "timestamp": timestamp
                }
            }
        },
        {
            "id": 3,
            "name": "⚠️ Alerta importante",
            "description": "Notificación de alta prioridad",
            "payload": {
                "to": DEVICE_TOKEN,
                "notification": {
                    "title": "⚠️ ALERTA IMPORTANTE",
                    "body": "Cambio en el calendario escolar - Revisa inmediatamente"
                },
                "data": {
                    "type": "alert",
                    "priority": "urgent",
                    "action": "open_calendar",
                    "test": "true",
                    "timestamp": timestamp
                },
                "priority": "high",
                "android": {
                    "priority": "high",
                    "notification": {
                        "sound": "default",
                        "color": "#d81b60",
                        "channel_id": "high_importance_channel"
                    }
                },
                "apns": {
                    "headers": {
                        "apns-priority": "10"
                    },
                    "payload": {
                        "aps": {
                            "sound": "default",
                            "badge": 1
                        }
                    }
                }
            }
        },
        {
            "id": 4,
            "name": "👨‍🏫 Actualización profesor",
            "description": "Información actualizada de profesor",
            "payload": {
                "to": DEVICE_TOKEN,
                "notification": {
                    "title": "👨‍🏫 Actualización de profesores",
                    "body": "Se ha actualizado la información del profesor Juan Pérez"
                },
                "data": {
                    "type": "teacher_update",
                    "teacher_id": "12345",
                    "area": "Psicología Clínica",
                    "test": "true",
                    "timestamp": timestamp
                }
            }
        },
        {
            "id": 5,
            "name": "⚙️ Notificación sistema",
            "description": "Actualización de la aplicación",
            "payload": {
                "to": DEVICE_TOKEN,
                "notification": {
                    "title": "⚙️ Actualización disponible",
                    "body": "Nueva versión de la app disponible en la tienda"
                },
                "data": {
                    "type": "app_update",
                    "version": "0.9.31",
                    "required": "false",
                    "test": "true",
                    "timestamp": timestamp
                }
            }
        },
        {
            "id": 6,
            "name": "📚 Recursos educativos",
            "description": "Material educativo nuevo disponible",
            "payload": {
                "to": DEVICE_TOKEN,
                "notification": {
                    "title": "📚 Nuevos recursos disponibles",
                    "body": "Material de estudio actualizado para el módulo 3"
                },
                "data": {
                    "type": "resources",
                    "module": "3",
                    "area": "Psicología Educativa",
                    "test": "true",
                    "timestamp": timestamp
                }
            }
        },
        {
            "id": 7,
            "name": "🔔 Notificación simple",
            "description": "Notificación básica sin datos extra",
            "payload": {
                "to": DEVICE_TOKEN,
                "notification": {
                    "title": "Hola estudiante",
                    "body": "Bienvenido a la app de Psicología SUAyED"
                },
                "data": {
                    "type": "welcome",
                    "test": "true",
                    "timestamp": timestamp
                }
            }
        }
    ]

def send_notification(payload: Dict, name: str, headers: Dict) -> bool:
    """Envía una notificación y retorna True si fue exitosa"""
    try:
        response = requests.post(FCM_URL, headers=headers, json=payload, timeout=10)

        if response.status_code == 200:
            data = response.json()
            if "success" in data and data["success"] >= 1:
                print(f"{Colors.GREEN}✅ {name}: Enviada correctamente{Colors.ENDC}")
                if "message_id" in data:
                    print(f"{Colors.BLUE}   Message ID: {data['message_id']}{Colors.ENDC}")
                return True
            else:
                print(f"{Colors.RED}❌ {name}: Fallo al enviar{Colors.ENDC}")
                print(f"   {Colors.RED}Response: {data}{Colors.ENDC}")
                return False
        else:
            print(f"{Colors.RED}❌ {name}: Error HTTP {response.status_code}{Colors.ENDC}")
            print(f"   {Colors.RED}{response.text}{Colors.ENDC}")
            return False

    except requests.exceptions.Timeout:
        print(f"{Colors.RED}❌ {name}: Timeout - El servidor tardó demasiado en responder{Colors.ENDC}")
        return False
    except requests.exceptions.ConnectionError:
        print(f"{Colors.RED}❌ {name}: Error de conexión - Verifica tu internet{Colors.ENDC}")
        return False
    except Exception as e:
        print(f"{Colors.RED}❌ {name}: Excepción - {str(e)}{Colors.ENDC}")
        return False

def print_header():
    """Imprime el encabezado del script"""
    print(f"\n{Colors.BLUE}{'━' * 60}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.BLUE}  🔔 Pruebas Automatizadas de Notificaciones Push{Colors.ENDC}")
    print(f"{Colors.BLUE}  📱 SUAyED Psicología FES Iztacala{Colors.ENDC}")
    print(f"{Colors.BLUE}{'━' * 60}{Colors.ENDC}\n")

def print_summary(results: Dict):
    """Imprime el resumen de las pruebas"""
    total = results['success'] + results['failed']
    success_rate = (results['success'] / total * 100) if total > 0 else 0

    print(f"\n{Colors.BLUE}{'━' * 60}{Colors.ENDC}")
    print(f"{Colors.BOLD}  📊 Resumen de Pruebas{Colors.ENDC}")
    print(f"{Colors.BLUE}{'━' * 60}{Colors.ENDC}\n")
    print(f"  Total enviadas:  {total}")
    print(f"  {Colors.GREEN}✅ Exitosas:      {results['success']}{Colors.ENDC}")
    print(f"  {Colors.RED}❌ Fallidas:      {results['failed']}{Colors.ENDC}")
    print(f"  {Colors.YELLOW}📈 Tasa de éxito: {success_rate:.1f}%{Colors.ENDC}")
    print(f"\n{Colors.BLUE}{'━' * 60}{Colors.ENDC}\n")

def main():
    """Función principal"""
    parser = argparse.ArgumentParser(description='Pruebas automatizadas de notificaciones push')
    parser.add_argument('--delay', type=int, default=5, help='Segundos de delay entre notificaciones (default: 5)')
    parser.add_argument('--cases', type=str, help='Casos de prueba a ejecutar (ej: 1,2,3). Si no se especifica, ejecuta todos')
    args = parser.parse_args()

    print_header()

    # Validar configuración
    if not validate_config():
        return

    # Preparar headers
    headers = {
        "Authorization": f"key={SERVER_KEY}",
        "Content-Type": "application/json"
    }

    # Obtener casos de prueba
    all_test_cases = get_test_cases()

    # Filtrar casos si se especificó --cases
    if args.cases:
        case_ids = [int(x.strip()) for x in args.cases.split(',')]
        test_cases = [tc for tc in all_test_cases if tc['id'] in case_ids]
        if not test_cases:
            print(f"{Colors.RED}❌ No se encontraron casos de prueba válidos{Colors.ENDC}")
            return
    else:
        test_cases = all_test_cases

    print(f"{Colors.YELLOW}⏰ Inicio: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}{Colors.ENDC}")
    print(f"{Colors.YELLOW}📦 Casos a ejecutar: {len(test_cases)}{Colors.ENDC}")
    print(f"{Colors.YELLOW}⏱️  Delay entre notificaciones: {args.delay}s{Colors.ENDC}\n")

    # Confirmar antes de enviar
    input(f"{Colors.YELLOW}Presiona ENTER para comenzar...{Colors.ENDC}")
    print()

    # Resultados
    results = {
        'success': 0,
        'failed': 0,
        'details': []
    }

    # Ejecutar casos de prueba
    for i, test in enumerate(test_cases, 1):
        print(f"{Colors.BOLD}[{i}/{len(test_cases)}] {test['name']}{Colors.ENDC}")
        print(f"  {test['description']}")

        success = send_notification(test['payload'], test['name'], headers)

        results['details'].append({
            'name': test['name'],
            'success': success
        })

        if success:
            results['success'] += 1
        else:
            results['failed'] += 1

        # Delay entre notificaciones (excepto en la última)
        if i < len(test_cases):
            print(f"{Colors.YELLOW}⏳ Esperando {args.delay} segundos...{Colors.ENDC}\n")
            time.sleep(args.delay)

    # Imprimir resumen
    print_summary(results)

    # Consejos finales
    print(f"{Colors.YELLOW}💡 Consejos:{Colors.ENDC}")
    print(f"  • Revisa la pantalla de Notificaciones en la app")
    print(f"  • Verifica que el badge counter se actualizó")
    print(f"  • Prueba marcar notificaciones como leídas")
    print(f"  • Ejecuta: {Colors.BLUE}flutter logs | grep notification{Colors.ENDC} para ver logs\n")

if __name__ == "__main__":
    main()
