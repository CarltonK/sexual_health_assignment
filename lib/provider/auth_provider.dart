import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sexual_health_assignment/models/models.dart';
import 'package:sexual_health_assignment/provider/provider.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth auth;
  User? currentUser;
  Status _status = Status.Uninitialized;

  Status get status => _status;
  User get user => currentUser!;

  DatabaseProvider database = DatabaseProvider();

  AuthProvider.instance() : auth = FirebaseAuth.instance {
    // Comment this line for production
    // auth.useAuthEmulator("192.168.100.11", 9099);
    auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /*
  AUTH LISTENER
  */
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      currentUser = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  /*
  USER REGISTRATION
  */
  Future createUser(UserModel user) async {
    _status = Status.Authenticating;
    notifyListeners();
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );
      currentUser = result.user;
      String uid = currentUser!.uid;

      // Save the user to the database
      await database.saveUser(user, uid);

      return Future.value(currentUser);
    } on FirebaseException catch (error) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return error.message;
    }
  }

  /*
  USER LOGIN
  */
  Future signInEmailPass(UserModel user) async {
    _status = Status.Authenticating;
    notifyListeners();
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
        email: user.email!,
        password: user.password!,
      );
      currentUser = result.user;

      return Future.value(currentUser);
    } on FirebaseAuthException catch (error) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return error.message;
    }
  }

  /*
  USER LOGOUT
  */
  Future<void> signOut() async {
    await auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }
}
