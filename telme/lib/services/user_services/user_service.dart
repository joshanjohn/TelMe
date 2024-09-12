import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telme/models/user_model.dart';

class UserService {
  final _userCollection = FirebaseFirestore.instance.collection("Users");

  Future<UserModel?> getUserInfo() async {
    try {
      String userId = await getUserID();
      DocumentSnapshot data = await _userCollection.doc(userId).get();
      return UserModel.fromJson(data);
    } catch (e) {
      print("Error on getUserinfo service");
      return null;
    }
  }

  Future<String> getUserID() async {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    return _pref.getString("userId")!;
  }
}
