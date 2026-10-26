import 'package:avaliacao_final_sctec/views/splash/splash_viewmodel.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {


  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final vm = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    Future.delayed(Duration(seconds: 2));

    final signedIn = await vm.isUserSignedIn();

    if(!mounted) return;
    signedIn ? Navigator.of(context).pushNamed("/home") : Navigator.of(context).pushNamed("/auth");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(Icons.eighteen_mp),
            Text("Conexão Chamados")
          ],
        ),
      ),
    );
  }
}
