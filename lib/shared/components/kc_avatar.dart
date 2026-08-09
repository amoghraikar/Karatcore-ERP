import 'package:flutter/material.dart';
import '../../core/constants/color_tokens.dart';

enum KcAvatarStatus { online, offline, busy, away }

class KcAvatar extends StatelessWidget {
  const KcAvatar({
    super.key,
    this.initials,
    this.imageUrl,
    this.size = 40,
    this.status,
    this.backgroundColor,
    this.textColor,
  });

  final String? initials;
  final String? imageUrl;
  final double size;
  final KcAvatarStatus? status;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? KcColors.carbon800 : KcColors.carbon950);
    final fg = textColor ?? (isDark ? KcColors.pureWhite : KcColors.pureWhite);

    final avatarCore = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.25),
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: imageUrl == null
          ? Text(
              (initials ?? 'KC').toUpperCase(),
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.38,
              ),
            )
          : null,
    );

    if (status == null) return avatarCore;

    Color statusColor;
    switch (status!) {
      case KcAvatarStatus.online:
        statusColor = KcColors.signalGreen;
        break;
      case KcAvatarStatus.offline:
        statusColor = KcColors.carbon400;
        break;
      case KcAvatarStatus.busy:
        statusColor = KcColors.signalRed;
        break;
      case KcAvatarStatus.away:
        statusColor = KcColors.signalOrange;
        break;
    }

    return Stack(
      children: [
        avatarCore,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? KcColors.carbon950 : KcColors.pureWhite,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class KcAvatarGroup extends StatelessWidget {
  const KcAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 3,
    this.size = 36,
  });

  final List<KcAvatar> avatars;
  final int maxVisible;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visible = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < visible.length; i++)
            Align(
              widthFactor: 0.75,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.25),
                  border: Border.all(
                    color: isDark ? KcColors.carbon950 : KcColors.pureWhite,
                    width: 2,
                  ),
                ),
                child: visible[i],
              ),
            ),
          if (remaining > 0)
            Align(
              widthFactor: 0.75,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isDark ? KcColors.carbon700 : KcColors.carbon200,
                  borderRadius: BorderRadius.circular(size * 0.25),
                  border: Border.all(
                    color: isDark ? KcColors.carbon950 : KcColors.pureWhite,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
