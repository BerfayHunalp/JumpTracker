import 'package:flutter/material.dart';
import '../../profile/widgets/avatar_widget.dart';
import '../community_providers.dart';

class FriendTile extends StatelessWidget {
  final FriendEntry friend;
  final VoidCallback? onRemove;

  const FriendTile({
    super.key,
    required this.friend,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          AvatarWidget(avatarIndex: friend.avatarIndex, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.nickname,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.person_remove,
                  color: Colors.white30, size: 20),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
