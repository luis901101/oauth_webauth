import 'package:example/src/auth_sample_screen.dart';
import 'package:example/src/base_redirect_sample_screen.dart';
import 'package:example/src/buttons.dart';
import 'package:flutter/material.dart';
import 'package:oauth_webauth/oauth_webauth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OAuthWebAuth.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'OAuth WebAuth samples'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = OAuthWebAuth.instance.restoreCodeVerifier() != null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          if (OAuthWebAuth.instance.restoreCodeVerifier() != null) {
            goAuthSampleScreen();
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              PrimaryButton(
                onPressed: () {
                  goAuthSampleScreen();
                },
                text: 'OAuth login samples',
              ),
              const SizedBox(height: 4),
              SecondaryButton(
                onPressed: () {
                  goBaseRedirectSampleScreen();
                },
                text: 'Base redirect samples',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goAuthSampleScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const AuthSampleScreen()));
  }

  void goBaseRedirectSampleScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const BaseRedirectSampleScreen()));
  }
}
