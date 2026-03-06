import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { superAdmin, engineer, worker }

enum AuthStatus { unauthenticated, pending, authenticated }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole? role;
  final AuthStatus status;
  final List<String> assignedGreenhouses;
  final bool isApproved;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    required this.status,
    this.assignedGreenhouses = const [],
    this.isApproved = false,
  });

  User copyWith({
    String? name,
    UserRole? role,
    AuthStatus? status,
    List<String>? assignedGreenhouses,
    bool? isApproved,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role ?? this.role,
      status: status ?? this.status,
      assignedGreenhouses: assignedGreenhouses ?? this.assignedGreenhouses,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  factory User.fromMap(String id, Map<String, dynamic> data) {
    UserRole? role;
    if (data['role'] != null) {
      role = UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.worker,
      );
    }

    final isApproved = data['isApproved'] ?? false;

    return User(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: role,
      status: isApproved ? AuthStatus.authenticated : AuthStatus.pending,
      assignedGreenhouses: List<String>.from(data['assignedGreenhouses'] ?? []),
      isApproved: isApproved,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role?.name,
      'isApproved': isApproved,
      'assignedGreenhouses': assignedGreenhouses,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class AuthService extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = true;
  StreamSubscription? _authSubscription;

  AuthService() {
    _listenToAuthChanges();
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _currentUser!.isApproved;
  bool get isPending => _currentUser != null && !_currentUser!.isApproved;
  bool get isLoading => _isLoading;

  List<User> _pendingUsers = [];
  List<User> get pendingUsers => _pendingUsers;

  void _listenToAuthChanges() {
    _authSubscription = _auth.authStateChanges().listen((
      fb_auth.User? fbUser,
    ) async {
      _isLoading = true;
      notifyListeners();

      if (fbUser != null) {
        final doc = await _firestore.collection('users').doc(fbUser.uid).get();
        if (doc.exists) {
          _currentUser = User.fromMap(fbUser.uid, doc.data()!);
        } else {
          // If profile missing, create a temp one
          _currentUser = User(
            id: fbUser.uid,
            name: fbUser.displayName ?? fbUser.email?.split('@')[0] ?? 'User',
            email: fbUser.email ?? '',
            status: AuthStatus.pending,
          );
        }
      } else {
        _currentUser = null;
      }

      _isLoading = false;
      notifyListeners();
    });

    // Listen to current user's document changes for instant approval feedback
    _auth.authStateChanges().listen((fb_user) {
      if (fb_user != null) {
        _firestore.collection('users').doc(fb_user.uid).snapshots().listen((
          doc,
        ) {
          if (doc.exists) {
            _currentUser = User.fromMap(fb_user.uid, doc.data()!);
            notifyListeners();
          }
        });
      }
    });

    // Listen to ALL pending users for Admin view
    _firestore
        .collection('users')
        .where('isApproved', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          _pendingUsers = snapshot.docs
              .map((doc) => User.fromMap(doc.id, doc.data()))
              .toList();
          notifyListeners();
        });
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final newUser = User(
        id: uid,
        name: email.split('@')[0],
        email: email,
        role: UserRole.worker, // Default
        status: AuthStatus.pending,
        isApproved: false,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      return true;
    } catch (e) {
      debugPrint("Registration error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveUser(
    String userId,
    UserRole role,
    List<String> houses,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      'role': role.name,
      'assignedGreenhouses': houses,
      'isApproved': true,
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
