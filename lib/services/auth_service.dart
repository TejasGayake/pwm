import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  Future<AppUser?> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return await _loadUserProfile(cred.user!.uid);
  }

  Future<AppUser?> register(String name, String email, String phone, String password, String role) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'name': name, 'email': email, 'phone': phone, 'role': role, 'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    _currentUser = AppUser(uid: cred.user!.uid, name: name, email: email, phone: phone, role: role, createdAt: DateTime.now());
    return _currentUser;
  }

  Future<AppUser?> _loadUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    _currentUser = AppUser.fromMap(uid, doc.data()!);
    return _currentUser;
  }

  Future<AppUser?> tryAutoLogin() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _loadUserProfile(user.uid);
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _auth.signOut();
  }

  bool get isLoggedIn => _auth.currentUser != null;
}
