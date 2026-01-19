#!/usr/bin/env python3
"""
Script para enviar notificaciones push FCM de forma manual
Aplicación: SUAyED Psicología FES Iztacala

Uso:
    uv run python send_notification.py --title "Título" --body "Mensaje"
    uv run python send_notification.py --token "FCM_TOKEN" --title "Título"
    uv run python send_notification.py --data '{"type": "post", "id": "123"}'

Autor: SUAyED Development Team
Fecha: 2026-01-18
"""

import argparse
import json
import logging
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any

import firebase_admin
from firebase_admin import credentials, messaging
from dotenv import load_dotenv

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('notification.log')
    ]
)
logger = logging.getLogger(__name__)


class FCMNotificationSender:
    """Clase para gestionar el envío de notificaciones FCM"""

    def __init__(self, service_account_path: str, project_id: str):
        """
        Inicializar el servicio de notificaciones FCM

        Args:
            service_account_path: Ruta al archivo service account JSON
            project_id: ID del proyecto Firebase
        """
        self.project_id = project_id
        self.service_account_path = service_account_path
        self._initialize_firebase()

    def _initialize_firebase(self):
        """Inicializar Firebase Admin SDK"""
        try:
            # Verificar que el archivo existe
            if not os.path.exists(self.service_account_path):
                raise FileNotFoundError(
                    f"Service account file not found: {self.service_account_path}"
                )

            # Inicializar Firebase Admin si no está inicializado
            if not firebase_admin._apps:
                cred = credentials.Certificate(self.service_account_path)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin SDK inicializado correctamente")
            else:
                logger.info("Firebase Admin SDK ya estaba inicializado")

        except Exception as e:
            logger.error(f"Error inicializando Firebase Admin SDK: {e}")
            raise

    def send_notification(
        self,
        token: str,
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None,
        image: Optional[str] = None,
        icon: str = "notification_icon",
        sound: str = "default",
        channel_id: str = "high_importance_channel"
    ) -> bool:
        """
        Enviar notificación push a un dispositivo

        Args:
            token: Token FCM del dispositivo
            title: Título de la notificación
            body: Cuerpo del mensaje
            data: Datos adicionales personalizados
            image: URL de imagen para la notificación
            icon: Icono de la notificación (Android)
            sound: Sonido de la notificación
            channel_id: ID del canal de notificación (Android)

        Returns:
            bool: True si se envió correctamente, False en caso contrario
        """
        try:
            # Validar token
            if not token or len(token) < 50:
                raise ValueError("Token FCM inválido o demasiado corto")

            # Agregar timestamp a los datos si existen
            if data is None:
                data = {}
            data['timestamp'] = datetime.now().isoformat()
            data['sent_from'] = 'manual_system'

            # Construir mensaje FCM
            message = messaging.Message(
                token=token,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                    image=image
                ),
                data=data,
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        icon=icon,
                        sound=sound,
                        click_action='FLUTTER_NOTIFICATION_CLICK',
                        channel_id=channel_id,
                        tag='suayed_notification',
                        color='#d81b60'  # Color institucional
                    )
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound=sound,
                            badge=1,
                            content_available=True,
                            category='suayed_notification'
                        )
                    )
                )
            )

            # Enviar mensaje
            response = messaging.send(message)
            logger.info(f"✅ Notificación enviada exitosamente. Message ID: {response}")

            # Log de detalles
            logger.info(f"   📱 Token (primeros 20 chars): {token[:20]}...")
            logger.info(f"   📝 Título: {title}")
            logger.info(f"   💬 Cuerpo: {body}")
            if image:
                logger.info(f"   🖼️  Imagen: {image}")
            if data:
                logger.info(f"   📦 Datos: {json.dumps(data, indent=2)}")

            return True

        except ValueError as e:
            logger.error(f"❌ Error de validación: {e}")
            return False
        except Exception as e:
            logger.error(f"❌ Error enviando notificación: {e}")
            logger.exception("Detalles del error:")
            return False

    def send_multicast(
        self,
        tokens: List[str],
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None,
        image: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Enviar notificación a múltiples dispositivos

        Args:
            tokens: Lista de tokens FCM
            title: Título de la notificación
            body: Cuerpo del mensaje
            data: Datos adicionales
            image: URL de imagen

        Returns:
            Dict con resultados: success_count, failure_count, responses
        """
        try:
            # Validar que no haya más de 500 tokens (límite FCM)
            if len(tokens) > 500:
                logger.warning(f"⚠️  Se intentaron enviar {len(tokens)} tokens. Límite: 500")
                tokens = tokens[:500]

            # Agregar timestamp a los datos
            if data is None:
                data = {}
            data['timestamp'] = datetime.now().isoformat()
            data['sent_from'] = 'manual_system_multicast'

            # Construir mensaje multicast
            message = messaging.MulticastMessage(
                tokens=tokens,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                    image=image
                ),
                data=data,
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        icon='notification_icon',
                        sound='default',
                        click_action='FLUTTER_NOTIFICATION_CLICK',
                        channel_id='high_importance_channel',
                        color='#d81b60'
                    )
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound='default',
                            badge=1,
                            content_available=True
                        )
                    )
                )
            )

            # Enviar mensajes
            response = messaging.send_multicast(message)

            logger.info(f"✅ Envío multicast completado:")
            logger.info(f"   📊 Total: {len(tokens)} dispositivos")
            logger.info(f"   ✅ Exitosos: {response.success_count}")
            logger.info(f"   ❌ Fallidos: {response.failure_count}")

            # Log de errores individuales
            if response.failure_count > 0:
                for idx, resp in enumerate(response.responses):
                    if not resp.success:
                        logger.error(f"   ❌ Token {idx}: {resp.exception}")

            return {
                'success_count': response.success_count,
                'failure_count': response.failure_count,
                'responses': response.responses
            }

        except Exception as e:
            logger.error(f"❌ Error en envío multicast: {e}")
            logger.exception("Detalles del error:")
            return {
                'success_count': 0,
                'failure_count': len(tokens),
                'error': str(e)
            }


def parse_arguments():
    """Parsear argumentos de línea de comando"""
    parser = argparse.ArgumentParser(
        description='Enviar notificaciones push FCM manualmente',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:
  # Notificación básica
  python send_notification.py --title "Hola" --body "Mensaje de prueba"

  # Con token específico
  python send_notification.py --token "FCM_TOKEN" --title "Hola"

  # Con datos personalizados
  python send_notification.py --title "Nuevo Post" --data '{"type":"post","id":"123"}'

  # Con imagen
  python send_notification.py --title "Evento" --image "https://example.com/img.jpg"

  # Multicast (múltiples tokens separados por comas)
  python send_notification.py --tokens "TOKEN1,TOKEN2,TOKEN3" --title "Hola a todos"
        """
    )

    parser.add_argument(
        '--token',
        type=str,
        help='Token FCM del dispositivo destino (usa FCM_TOKEN del .env si no se especifica)'
    )

    parser.add_argument(
        '--tokens',
        type=str,
        help='Múltiples tokens FCM separados por comas para envío multicast'
    )

    parser.add_argument(
        '--title',
        type=str,
        help='Título de la notificación (usa DEFAULT_TITLE del .env si no se especifica)'
    )

    parser.add_argument(
        '--body',
        type=str,
        help='Cuerpo del mensaje (usa DEFAULT_BODY del .env si no se especifica)'
    )

    parser.add_argument(
        '--data',
        type=str,
        help='Datos adicionales en formato JSON, ej: \'{"type":"post","id":"123"}\''
    )

    parser.add_argument(
        '--image',
        type=str,
        help='URL de imagen para mostrar en la notificación'
    )

    parser.add_argument(
        '--icon',
        type=str,
        help='Icono de notificación (Android, usa DEFAULT_ICON del .env si no se especifica)'
    )

    parser.add_argument(
        '--sound',
        type=str,
        help='Sonido de notificación (usa DEFAULT_SOUND del .env si no se especifica)'
    )

    return parser.parse_args()


def main():
    """Función principal"""
    try:
        # Cargar variables de entorno
        env_path = Path(__file__).parent / '.env'
        if not env_path.exists():
            logger.warning(f"⚠️  Archivo .env no encontrado en {env_path}")
            logger.warning("   Creando .env desde .env.example...")

            example_path = Path(__file__).parent / '.env.example'
            if example_path.exists():
                import shutil
                shutil.copy(example_path, env_path)
                logger.info("   ✅ Archivo .env creado. Por favor configúralo y vuelve a ejecutar.")
                sys.exit(1)
            else:
                logger.error("   ❌ Tampoco existe .env.example. Verifica la instalación.")
                sys.exit(1)

        load_dotenv(env_path)
        logger.info("📄 Variables de entorno cargadas")

        # Obtener configuración
        project_id = os.getenv('FIREBASE_PROJECT_ID', 'app-de-psicologia-suayed')
        service_account = os.getenv('FIREBASE_SERVICE_ACCOUNT', './service-account.json')

        # Convertir a ruta absoluta si es relativa
        if not os.path.isabs(service_account):
            service_account = str(Path(__file__).parent / service_account)

        # Parsear argumentos
        args = parse_arguments()

        # Obtener valores (args tienen prioridad sobre .env)
        fcm_token = args.token or os.getenv('FCM_TOKEN')
        title = args.title or os.getenv('DEFAULT_TITLE', 'Psicología SUAyED')
        body = args.body or os.getenv('DEFAULT_BODY', 'Mensaje de prueba')
        icon = args.icon or os.getenv('DEFAULT_ICON', 'notification_icon')
        sound = args.sound or os.getenv('DEFAULT_SOUND', 'default')

        # Parsear datos JSON si existen
        data = None
        if args.data:
            try:
                data = json.loads(args.data)
            except json.JSONDecodeError as e:
                logger.error(f"❌ Error parseando JSON de datos: {e}")
                sys.exit(1)

        # Inicializar sender
        logger.info(f"🚀 Inicializando FCM Notification Sender")
        logger.info(f"   📦 Proyecto: {project_id}")
        logger.info(f"   🔑 Service Account: {service_account}")

        sender = FCMNotificationSender(service_account, project_id)

        # Decidir entre envío simple o multicast
        if args.tokens:
            # Envío multicast
            tokens_list = [t.strip() for t in args.tokens.split(',')]
            logger.info(f"\n📡 Enviando notificación multicast a {len(tokens_list)} dispositivos...")

            result = sender.send_multicast(
                tokens=tokens_list,
                title=title,
                body=body,
                data=data,
                image=args.image
            )

            if result['success_count'] > 0:
                logger.info(f"\n🎉 Notificaciones enviadas exitosamente!")
                sys.exit(0)
            else:
                logger.error(f"\n❌ Todas las notificaciones fallaron")
                sys.exit(1)
        else:
            # Envío simple
            if not fcm_token:
                logger.error("❌ No se especificó token FCM. Usa --token o configura FCM_TOKEN en .env")
                sys.exit(1)

            logger.info(f"\n📡 Enviando notificación...")

            success = sender.send_notification(
                token=fcm_token,
                title=title,
                body=body,
                data=data,
                image=args.image,
                icon=icon,
                sound=sound
            )

            if success:
                logger.info(f"\n🎉 Notificación enviada exitosamente!")
                sys.exit(0)
            else:
                logger.error(f"\n❌ Error enviando notificación")
                sys.exit(1)

    except KeyboardInterrupt:
        logger.info("\n⚠️  Operación cancelada por el usuario")
        sys.exit(0)
    except Exception as e:
        logger.error(f"\n❌ Error fatal: {e}")
        logger.exception("Detalles del error:")
        sys.exit(1)


if __name__ == '__main__':
    main()
