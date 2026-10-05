import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post_it_model.dart';

const Map<String, IconData> kMagnetIcons = {
  'pin': Icons.push_pin,
  'star': Icons.star,
  'heart': Icons.favorite,
  'flower': Icons.local_florist,
};

/// Card visual de um post-it, "preso" na geladeira com um ímã no topo.
///
/// Puramente visual — não trata toque nem arraste (isso é feito por quem
/// usa este widget, ver `DraggablePostIt`), pra não conflitar com o
/// GestureDetector de arrastar.
class PostItWidget extends StatelessWidget {
  final PostItModel postIt;
  final double size;

  const PostItWidget({super.key, required this.postIt, this.size = 110});

  Color get _color {
    try {
      return Color(int.parse(postIt.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFFFFF176);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pequena rotação "física" baseada no id, para parecer um post-it
    // real colado meio torto na geladeira.
    final angle = ((postIt.id.hashCode % 7) - 3) / 80;

    final statusIcon = switch (postIt.status) {
      PostItStatus.completed => Icons.check_circle,
      PostItStatus.late => Icons.warning_amber_rounded,
      PostItStatus.pending => Icons.schedule,
    };
    final statusColor = switch (postIt.status) {
      PostItStatus.completed => Colors.green[700],
      PostItStatus.late => Colors.red[700],
      PostItStatus.pending => Colors.black54,
    };

    return Transform.rotate(
      angle: angle,
      child: Material(
        color: _color,
        elevation: 3,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.fromLTRB(size * 0.07, size * 0.14, size * 0.07, size * 0.07),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -size * 0.14,
                left: size * 0.42,
                child: Icon(
                  kMagnetIcons[postIt.magnetIcon] ?? Icons.push_pin,
                  color: Colors.black54,
                  size: size * 0.16,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postIt.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: size * 0.1),
                  ),
                  SizedBox(height: size * 0.03),
                  Expanded(
                    child: Text(
                      postIt.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: size * 0.08),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(statusIcon, size: size * 0.11, color: statusColor),
                      SizedBox(width: size * 0.03),
                      Expanded(
                        child: Text(
                          postIt.completed
                              ? 'Concluído por ${postIt.completedByName ?? '-'}'
                              : postIt.dueDate != null
                                  ? DateFormat('dd/MM').format(postIt.dueDate!)
                                  : postIt.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: size * 0.07, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
