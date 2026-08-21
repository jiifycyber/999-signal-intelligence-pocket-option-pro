import 'package:flutter/material.dart';

class PlatformShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  const PlatformShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF020811);
    const panel = Color(0xFF08121D);
    const border = Color(0xFF163247);
    const cyan = Color(0xFF13D8FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Icon(icon, color: cyan),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: children
            .map(
              (child) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
}

class PlatformToolTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  const PlatformToolTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF13D8FF);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cyan.withOpacity(.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cyan.withOpacity(.3)),
        ),
        child: Icon(icon, color: cyan),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white38,
      ),
    );
  }
}
