import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

/// Avatar do paciente padronizado para o fluxo de nova consulta
class ConsultationAvatar extends StatelessWidget {
  final String? avatarUrl;
  final bool isLoading;
  final VoidCallback? onTap;

  const ConsultationAvatar({
    super.key,
    this.avatarUrl,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/patient/account'),
      child: isLoading
          ? const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.canfyGreen,
              ),
            )
          : avatarUrl != null && avatarUrl!.isNotEmpty
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(avatarUrl!),
                  onBackgroundImageError: (_, __) {},
                )
              : const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.neutral300,
                  child: Icon(
                    Icons.person,
                    color: AppColors.neutral600,
                  ),
                ),
    );
  }
}
