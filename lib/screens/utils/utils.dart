import 'package:flutter/material.dart';

Future<bool?> confirmationDialog(title, content, context) async {
    return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            content:
                Text(content, style: Theme.of(context).textTheme.bodyMedium),
            actions: [
              OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Não",
                      style: Theme.of(context).textTheme.bodyMedium)),
              OutlinedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Sim",
                      style: Theme.of(context).textTheme.bodyMedium))
            ],
          );
        });
  }