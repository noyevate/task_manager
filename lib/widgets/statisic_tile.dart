import 'package:flutter/material.dart';

class StatisicTile extends StatelessWidget {
  final String? statsHeading;
  final String? stats;

  const StatisicTile({super.key, this.stats, this.statsHeading, });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
              EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    offset: const Offset(0, 4),
                    blurRadius: 10)
              ]),
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statsHeading!),
                  Center(
                    child: Text(stats!),
                  )
                ],
              ),
              
    );
  }
}