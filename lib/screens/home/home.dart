import 'package:flutter/material.dart';
import 'package:quem_sou_eu/theme/backgroud_theme.dart';
import 'package:quem_sou_eu/theme/container_theme.dart';
import 'package:quem_sou_eu/theme/square_button_theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // than having to individually change instances of widgets.
    return Scaffold(
        /*appBar: AppBar(
          flexibleSpace: Container(
            decoration: containerTheme(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(
                  "Quem sou eu",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                )),
              ],
            ),
          ),
        ),*/
        body: Container(
      decoration: backgroundTheme(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 60,
            ),
            Image.asset(
              "lib/assets/images/logo2.png",
              width: 250,
              height: 250,
            ),
            const SizedBox(
              height: 60,
            ),
            Container(
              decoration: buttonContainerTheme(context),
              child: ElevatedButton(
                style: squareButtonTheme().copyWith(
                    fixedSize: MaterialStateProperty.all(Size.fromWidth(300))),
                onPressed: () {
                  Navigator.pushNamed(context, '/hostGame');
                },
                child: Text(
                  "Criar sala",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: buttonContainerTheme(context),
              child: ElevatedButton(
                  style: squareButtonTheme().copyWith(
                      fixedSize:
                          MaterialStateProperty.all(Size.fromWidth(300))),
                  onPressed: () {
                    Navigator.pushNamed(context, '/findLobby');
                  },
                  child: Text("Entrar em sala",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary))),
            ),
          ],
        ),
      ),
    ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
