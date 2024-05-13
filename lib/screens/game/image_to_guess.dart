import 'package:flutter/material.dart';

class ImagesToGuess extends StatelessWidget {
  const ImagesToGuess(
      {super.key,
      required this.images,
      required this.callBackFunction,
      required this.indexImageSelected});

  final List<String> images;
  final Function(int) callBackFunction;
  final int indexImageSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2))),
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (indexImageSelected == index) {
                  return Colors.green.withOpacity(0.5);
                } else {
                  return Colors.transparent;
                } 
              },
            ),
            foregroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            overlayColor: MaterialStateProperty.all<Color>(
                Colors.transparent), // Defer to the widget's default.
          ),
          onPressed: () {
            callBackFunction(index);
          },
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}