import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  User? _user;
  String? _name;
  String? _profilePicture;
  int _wins = 0;
  int _losses = 0;
  int _gamesPlayed = 0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 Load user data from Firestore
  void _loadUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("players").doc(_user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _name = userDoc["name"];
          _profilePicture = userDoc["profile_picture"];
          _wins = userDoc["wins"];
          _losses = userDoc["losses"];
          _gamesPlayed = userDoc["games_played"];
        });
      } else {
        // If new user, create a Firestore document
        await _firestore.collection("players").doc(_user!.uid).set({
          "name": _user!.displayName ?? "New Player",
          "email": _user!.email,
          "profile_picture": _user!.photoURL ?? "",
          "wins": 0,
          "losses": 0,
          "games_played": 0,
        });
        _loadUserData();
      }
    }
  }

  // 🔹 Select and upload a new profile picture
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File file = File(image.path);
    String fileName = "profile_pics/${_user!.uid}.jpg";
    UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    await _firestore.collection("players").doc(_user!.uid).update({"profile_picture": downloadUrl});
    setState(() {
      _profilePicture = downloadUrl;
    });
  }

  // 🔹 Save updated name
  void _updateName() async {
    if (_name != null && _name!.isNotEmpty) {
      await _firestore.collection("players").doc(_user!.uid).update({"name": _name});
      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicture != null && _profilePicture!.isNotEmpty
                    ? NetworkImage(_profilePicture!)
                    : AssetImage("assets/default_profile.png") as ImageProvider,
              ),
            ),
            SizedBox(height: 10),
            _isEditing
                ? TextField(
                    onChanged: (value) => _name = value,
                    onSubmitted: (_) => _updateName(),
                    decoration: InputDecoration(hintText: "Enter name"),
                  )
                : Text(_name ?? "Loading...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
            SizedBox(height: 20),
            Text("Wins: $_wins | Losses: $_losses | Games Played: $_gamesPlayed", style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
