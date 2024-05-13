import 'package:flutter/material.dart';
import 'package:quem_sou_eu/screens/host_game/host_game_form.dart';

class HostGame extends StatelessWidget {
  const HostGame({super.key});


  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Hospedar jogo", style: Theme.of(context).textTheme.bodyLarge,),
      ),
      body: const Padding(
      padding: EdgeInsets.fromLTRB(20,20,20,20),
      child: HostGameForm(),
      ),
    );
  }
}