import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';

class Model {
  final int id;
  final IconData icon;
  final String name;

  Model({
    required this.id,
    required this.icon,
    required this.name,
  });
}

List<Model> navBtn = [
  Model(id: 0, icon: LucideIcons.home, name: 'Home'),
  Model(id: 1, icon: LucideIcons.user, name: 'Profile'),
];