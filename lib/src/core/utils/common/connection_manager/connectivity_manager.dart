import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../presentation/bloc/global/global_bloc.dart' show GlobalBloc, GlobalNetworkAvailableEvent;

class ConnectivityManager {
  bool isAvailable = true;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? subscription;
  final PublishSubject<bool> _stream = PublishSubject();
  final GlobalBloc _globalBloc;

  ConnectivityManager(this._globalBloc);

  void init() {
    if (Platform.isAndroid || Platform.isIOS) {
      if (subscription != null) {
        subscription?.cancel();
      }
      subscription = _connectivity.onConnectivityChanged.listen((event) {
        isAvailable = (event.contains(ConnectivityResult.ethernet)) ||
            (event.contains(ConnectivityResult.mobile)) ||
            (event.contains(ConnectivityResult.wifi)) ||
            (event.contains(ConnectivityResult.vpn));
        if (isAvailable) {
          _stream.sink.add(true);
          _onAvailable();
        }
      });
    }
  }

  Future<bool> checkForConnection() async {
    // final result = (await _connectivity.checkConnectivity());
    // return result != ConnectivityResult.none && result != ConnectivityResult.bluetooth;

    final result = await InternetConnection().hasInternetAccess;
    _stream.sink.add(result);
    return result;
  }

  void _onAvailable() {
    _globalBloc.add(GlobalNetworkAvailableEvent());
  }

  Future<void> waitForConnection() async {
    await _stream.stream.firstWhere((element) => element);
    isAvailable = true;
    _onAvailable();
  }
}
