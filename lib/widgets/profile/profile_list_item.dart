import 'package:flutter/material.dart';

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool showDivider;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ProfileListItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.showDivider = true,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? Theme.of(context).iconTheme.color?.withOpacity(0.6) ?? Colors.black54, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF2E3333),
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 56.0, right: 16),
              child: Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
        ],
      ),
    );
  }
}
