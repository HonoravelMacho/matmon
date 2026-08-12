import 'package:flutter/material.dart';
class MenuCard extends StatelessWidget {
  final String title; final IconData icon; final Color color; final VoidCallback onTap;
  MenuCard({required this.title, required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(leading: Icon(icon, color: color), title: Text(title), onTap: onTap));
  }
}