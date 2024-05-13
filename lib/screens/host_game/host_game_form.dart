import 'package:flutter/material.dart';
import 'package:quem_sou_eu/data/player/host.dart';
import 'package:quem_sou_eu/screens/game/game.dart';

class HostGameForm extends StatefulWidget {
  const HostGameForm({super.key});

  @override
  State<HostGameForm> createState() => _HostGameFormState();
}

class _HostGameFormState extends State<HostGameForm> {
  final _formKey = GlobalKey<FormState>();
  final nickController = TextEditingController();
  final portController = TextEditingController();
  final lobbyNameController = TextEditingController();
  final themeController = TextEditingController();


  String? validatorForWords(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? validatorForNumber(String? value) {
    int? number = value != null ? int.parse(value) : null;
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    } else if (number == null || number < 2000 || number > 63000) {
      return 'Necessário que seja um numero entre 2000 e 63000';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              validator: validatorForWords,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                  labelText: "Nome da sala",
                  labelStyle: Theme.of(context).textTheme.bodyMedium),
            ),
            TextFormField(
              controller: nickController,
              validator: validatorForWords,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                  labelText: "Seu nick",
                  labelStyle: Theme.of(context).textTheme.bodyMedium),
            ),
            TextFormField(
              validator: validatorForWords,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                  labelText: "Tema",
                  labelStyle: Theme.of(context).textTheme.bodyMedium),
            ),
            TextFormField(
              controller: portController,
              validator: validatorForNumber,
              style: Theme.of(context).textTheme.bodySmall,
              decoration: InputDecoration(
                  labelText: "Porta",
                  labelStyle: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Game(
                                player: Host(nickController.text),
                                port: int.parse(portController.text)
                              )),
                    );
                  }
                },
                child: const Text("Criar"))
          ],
        ));
  }
}
