import 'package:flutter/material.dart';

import 'package:ecustock/core/utils/permission_helper.dart';

/// Widget que oculta o muestra su hijo según el permiso del usuario.
class PermissionGuard extends StatelessWidget {
  const PermissionGuard({
    super.key,
    required this.permission,
    required this.child,
    this.deniedChild,
  });

  final String permission;
  final Widget child;
  final Widget? deniedChild;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PermissionHelper().hasPermission(permission),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return child;
        }

        return deniedChild ?? const SizedBox.shrink();
      },
    );
  }
}
