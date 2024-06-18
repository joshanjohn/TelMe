import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future login(email, password) async{
    try{
      //try get credentials from supplied email and password
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password:password
      );
      User? user = credential.user;
      return user;
    }catch(err){
      return err.toString();
    }
  }

}