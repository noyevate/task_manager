import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityState {
  final bool isOnline;
  const ConnectivityState(this.isOnline);
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _sub;

  ConnectivityCubit() : super(const ConnectivityState(true)) {
    _init();
  }

  Future<void> _init() async {
    final res = await _connectivity.checkConnectivity();
    emit(ConnectivityState(_resultIsOnline(res)));
    _sub = _connectivity.onConnectivityChanged.listen((r) {
      final online = _resultIsOnline(r);
      emit(ConnectivityState(online));
    });
  }

  bool _resultIsOnline(ConnectivityResult r) {
    return r == ConnectivityResult.mobile || r == ConnectivityResult.wifi;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
