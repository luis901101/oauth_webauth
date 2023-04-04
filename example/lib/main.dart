import 'package:example/src/auth_sample_screen.dart';
import 'package:example/src/base_redirect_sample_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oauth_webauth/oauth_webauth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OauthWebAuth.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Oauth WebAuth samples'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = OauthWebAuth.instance.restoreCodeVerifier() != null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          if (OauthWebAuth.instance.restoreCodeVerifier() != null) {
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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  goAuthSampleScreen();
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
                child: const Text('Oauth login samples'),
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {
                  goBaseRedirectSampleScreen();
                },
                child: const Text('Base redirect samples'),
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
