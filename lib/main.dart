import 'package:firebase_operations/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  initNotifications();
  runApp(const MyApp());
}

Future<void> initNotifications() async{
  final firebaseMessaging  = FirebaseMessaging.instance;
  await firebaseMessaging.requestPermission();
  String? token = await FirebaseMessaging.instance.getToken();
  print('fcm> $token');
  FirebaseMessaging.onBackgroundMessage(handleMessage);
}

Future<void> handleMessage(RemoteMessage message) async{
print('message> ${message.data}');
print(message.notification!.title);
print(message.notification!.body);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.transparent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  String? verifyId = '';
  TextEditingController passwordController = TextEditingController();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            TextField(
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Enter Number',
                enabled: true,
                filled: false,
                fillColor: Color(0xFFfdfffd),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow, width: 0.0),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
           const SizedBox(height: 20,),
            TextButton(
                onPressed: (){
                  verifyPhoneNumber('+919032012520');

            }, child: Text('Send')),
            const SizedBox(height: 20,),
            TextField(
              controller: passwordController,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
                enabled: true,
                filled: false,
                fillColor: Color(0xFFfdfffd),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow, width: 0.0),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            TextButton(
                onPressed: (){
                  signInWithOTP(verifyId!,passwordController.text.trim());
            }, child: Text('Send Otp'))
          ],
        ),
      ),

    );
  }


  Future<void> verifyPhoneNumber(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Start the phone number verification process
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential)  {},
      verificationFailed: (FirebaseAuthException authException) {},
      codeSent: (String verificationId, [int? forceResendingToken])  {
        verifyId = verificationId;
        setState(() {

        });
      },
      codeAutoRetrievalTimeout: (String verificationId){},
    );
  }



  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // Create a PhoneAuthCredential with the verificationId and smsCode
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in the user with the credential
      await auth.signInWithCredential(credential);

      // The user is now signed in
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepgae()));
      print('User signed in successfully');
    } catch (e) {
      print('Error signing in with OTP: $e');
      // Handle sign-in errors
    }
  }


}
