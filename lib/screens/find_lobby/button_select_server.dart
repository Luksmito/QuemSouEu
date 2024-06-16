import 'package:flutter/material.dart';

class ButtonSelectServer extends StatefulWidget {
  ButtonSelectServer({
    super.key,
    required this.callback,
    required this.servidor,
  });

  final VoidCallback callback;
  final bool servidor;

  @override
  State<ButtonSelectServer> createState() => _ButtonSelectServerState();
}

class _ButtonSelectServerState extends State<ButtonSelectServer> {
  ButtonStyle style(servidor) {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith(
        (states) => servidor ? Colors.lightGreenAccent : Colors.grey,
      ),
      elevation: MaterialStateProperty.resolveWith(
        (states) => servidor ? 10 : 0,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          side: servidor
              ? const BorderSide(color: Colors.green, width: 4)
              : BorderSide.none,
          borderRadius: BorderRadius.only(
              topLeft: servidor ? const Radius.circular(10) : Radius.zero,
              bottomLeft: servidor ? const Radius.circular(10) : Radius.zero,
              topRight: !servidor ? const Radius.circular(10) : Radius.zero,
              bottomRight: !servidor ? const Radius.circular(10) : Radius.zero),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: widget.servidor
                  ? [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              style:style(widget.servidor).copyWith(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    side: widget.servidor
                        ? const BorderSide(color: Colors.green, width: 4)
                        : BorderSide.none,
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(10),
                      bottomLeft:  Radius.circular(10),
                    ),
                  ),
                ),
              ),
              child: Text(
                "Servidor",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                widget.callback();
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: !widget.servidor
                  ? [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              style: style(!widget.servidor).copyWith(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    side: !widget.servidor
                        ? const BorderSide(color: Colors.green, width: 4)
                        : BorderSide.none,
                    borderRadius: const BorderRadius.only(
                      topRight:  Radius.circular(10),
                      bottomRight:  Radius.circular(10),
                    ),
                  ),
                ),
              ),
              child: Text(
                "Local",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                widget.callback();
              },
            ),
          ),
        ),
      ],
    );
  }
}
