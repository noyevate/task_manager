import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/providers/connectivity_cubit.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (state.isOnline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: const Color.fromARGB(255, 232, 163, 163),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.signal_wifi_off, color: Colors.white, size: 12),
                SizedBox(width: 8),
                Text('You are offline — changes are saved locally', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
