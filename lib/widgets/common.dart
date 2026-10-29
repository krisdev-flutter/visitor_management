import 'package:flutter/material.dart';
import 'package:visitor_management_task/models/visitor.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Checked In' => const Color(0xFF16845B),
      'Checked Out' => const Color(0xFF64748B),
      _ => const Color(0xFFB7791F),
    };
    final icon = switch (status) {
      'Checked In' => Icons.radio_button_checked,
      'Checked Out' => Icons.check_circle_outline,
      _ => Icons.schedule_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class VisitorCard extends StatelessWidget {
  const VisitorCard({
    super.key,
    required this.visitor,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });
  final Visitor visitor;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final initials = visitor.name.trim().isEmpty
        ? '?'
        : visitor.name.trim()[0].toUpperCase();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF245BDB),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visitor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF17243B),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_iphone_rounded,
                              size: 14,
                              color: Color(0xFF8290A5),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                visitor.mobile,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF65728A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(child: StatusChip(status: visitor.status)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.apartment_rounded,
                    size: 16,
                    color: Color(0xFF8290A5),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      visitor.project,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF42516A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB8C2D1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    visitor.visitorType,
                    style: const TextStyle(
                      color: Color(0xFF65728A),
                      fontSize: 12,
                    ),
                  ),
                  if (onEdit != null || onDelete != null) ...[
                    const SizedBox(width: 4),
                    if (onEdit != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Edit visitor',
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 19,
                          color: Color(0xFF52627A),
                        ),
                      ),
                    if (onDelete != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Delete visitor',
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: Color(0xFFCC4B4B),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle = 'Try changing your search or add a visitor.',
  });
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              size: 34,
              color: Color(0xFF245BDB),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17243B),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF75839A), height: 1.45),
          ),
        ],
      ),
    ),
  );
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}
