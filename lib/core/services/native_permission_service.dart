import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NativePermissionService {
  const NativePermissionService._();

  static Future<PermissionStatus> requestCameraPermission(
    BuildContext context,
  ) async {
    return _requestPermission(
      context: context,
      permission: Permission.camera,
      title: 'Permiso de cámara',
      description:
          'EcuStock necesita acceder a la cámara para leer códigos de barras y QR de productos durante movimientos de bodega y ventas.',
      settingsTitle: 'La cámara está desactivada',
      settingsDescription:
          'Activa la cámara desde Ajustes para seguir escaneando códigos con EcuStock.',
    );
  }

  static Future<PermissionStatus> requestNotificationPermission(
    BuildContext context,
  ) async {
    return _requestPermission(
      context: context,
      permission: Permission.notification,
      title: 'Alertas de inventario',
      description:
          'EcuStock puede enviar avisos de stock crítico para ayudarte a reaccionar antes de que un producto quede sin existencias.',
      settingsTitle: 'Las notificaciones están desactivadas',
      settingsDescription:
          'Activa las notificaciones en Ajustes para recibir alertas de inventario crítico.',
    );
  }

  static Future<PermissionStatus> _requestPermission({
    required BuildContext context,
    required Permission permission,
    required String title,
    required String description,
    required String settingsTitle,
    required String settingsDescription,
  }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return status;
    }

    if (status.isPermanentlyDenied || status.isRestricted || status.isLimited) {
      // ignore: use_build_context_synchronously
      if (!context.mounted) {
        return status;
      }
      await _showSettingsDialog(
        context: context,
        title: settingsTitle,
        description: settingsDescription,
      );
      return status;
    }

    // ignore: use_build_context_synchronously
    if (!context.mounted) {
      return status;
    }
    final shouldContinue = await _showRationaleDialog(
      context: context,
      title: title,
      description: description,
    );

    if (!shouldContinue) {
      return status;
    }

    final requested = await permission.request();

    if (requested.isPermanentlyDenied) {
      // ignore: use_build_context_synchronously
      if (!context.mounted) {
        return requested;
      }
      await _showSettingsDialog(
        context: context,
        title: settingsTitle,
        description: settingsDescription,
      );
    }

    return requested;
  }

  static Future<bool> _showRationaleDialog({
    required BuildContext context,
    required String title,
    required String description,
  }) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.security_outlined,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title),
              ),
            ],
          ),
          content: Text(
            description,
            style: const TextStyle(height: 1.3),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Continuar'),
            ),
          ],
        );
      },
    );

    return shouldContinue ?? false;
  }

  static Future<void> _showSettingsDialog({
    required BuildContext context,
    required String title,
    required String description,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Más tarde'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await openAppSettings();
              },
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Ajustes'),
            ),
          ],
        );
      },
    );
  }
}
