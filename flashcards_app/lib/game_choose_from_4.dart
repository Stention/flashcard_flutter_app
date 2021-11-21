import 'package:flutter/material.dart';

class ChooseFrom4Game extends StatelessWidget {
  final int id;
  const ChooseFrom4Game({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find the right translation"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Row(children: <Widget>[
          Expanded(
              child: SizedBox(
                  height: 75,
                  child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red[200],
                          textStyle: const TextStyle(fontSize: 17)),
                      child: const Text("1")))),
          Expanded(
              child: SizedBox(
                  height: 75,
                  child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red[200],
                          textStyle: const TextStyle(fontSize: 17)),
                      child: const Text("2"))))
        ]),
        Row(children: <Widget>[
          Expanded(
              child: SizedBox(
                  height: 75,
                  child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red[200],
                          textStyle: const TextStyle(fontSize: 17)),
                      child: const Text("3")))),
          Expanded(
              child: SizedBox(
                  height: 75,
                  child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red[200],
                          textStyle: const TextStyle(fontSize: 17)),
                      child: const Text("4"))))
        ])
      ]),
    );
  }
}
