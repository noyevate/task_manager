import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class FaB extends StatelessWidget {
  const FaB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: Key('addTaskFab'),
      onPressed: () {
       
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 20,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
