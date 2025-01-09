import 'package:firebase_auth/firebase_auth.dart';
import 'package:listing_app_flutter/widgets/customized_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/firebase_auth_service.dart';
import '../colors.dart';
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.welcomeColor
          // image: DecorationImage(image: AssetImage("assets/background.png")) // in case of background image
            ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(
              height: 360,
              width: 360,
              child: Image(
                  image: AssetImage("assets/food_logo_black.png"), fit: BoxFit.cover),
            ),
            const SizedBox(height: 40),
            CustomizedButton(
              buttonText: "Login",
              buttonColor: AppColors.primaryColor,
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await FirebaseAuthService().logininwithgoogle();
                  if (FirebaseAuth.instance.currentUser != null) {
                    if (!mounted) return;
                    context.push('/menu');
                  } else {
                    throw Exception("Error");
                  }
                } on Exception catch (exception) {
    print(exception);
    } catch (error) {
                  print(error);
    }

              },
            ),
            const SizedBox(height: 20),
            CustomizedButton(
              buttonText: "Continue as a Guest",
              buttonColor: AppColors.secondaryColor,
              textColor: Colors.white,
              onPressed: () async {
                context.push('/menu');
              },
            ),
          ],
        ),
      ),
    );
  }
}
