import 'package:auth_secure_storage/cubits/auth_cubit.dart';
import 'package:auth_secure_storage/pages/login_page.dart';
import 'package:auth_secure_storage/states/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('Home Page'),
          backgroundColor: Colors.indigo[800],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(
                          'Are you sure you want to logout from home page?',
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.indigo[800], // Dark button
                              foregroundColor: Colors.white, // White text
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              context.read<AuthCubit>().logout();
                              Navigator.pop(context);
                            },
                            child: Text('Yes'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.indigo[800], // Dark button
                              foregroundColor: Colors.white, // White text
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('No'),
                          ),
                        ],
                      ),
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),

        body: Center(child: Text("You're logged in!")),
      ),
    );
  }
}
