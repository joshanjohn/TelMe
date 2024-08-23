import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telme/models/user_model.dart';

class UserService {
  final _userCollection = FirebaseFirestore.instance.collection("Users");

  Future<UserModel?> getUserInfo() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    try {
      String userId = _pref.getString("userId")!;
      DocumentSnapshot data = await _userCollection.doc(userId).get();
      return UserModel.fromJson(data);
    }  catch(e) {
      print("Error on getUserinfo service");
      return null;
    }
  }
}
