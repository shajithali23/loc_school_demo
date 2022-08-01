import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/home_screen.dart';
import '../pages/login_screen.dart';

class FirebaseService{
   final _auth = FirebaseAuth.instance;

  handleSignIn(String email,String password,BuildContext context)async{
    try {
                              
                              var response=  await _auth.signInWithEmailAndPassword(
                                  email: email, password:password);
                                 await checkUserRole(_auth.currentUser!.uid.toString(),context);
                              
                              
                            } on FirebaseAuthException catch (e) {
                              debugPrint(e.toString());
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ops! Login Failed'),
                                  duration: Duration(seconds: 5),
                                ),
                              );
  }}

 Future  signOut(context)  async{
    await _auth.signOut();
  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>LoginScreen()));
    
}

checkUserRole(userId,context)async{
 try{

 var data=await FirebaseFirestore.instance
          .collection("users")
         .doc(userId)
         .get()
         .then((value) {
          print(value.get("role"));
          if(value.get("role")=="Nanny"){
            print("LOGIN");
            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sucessfully Login.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) =>  HomePage()),
                                  (Route<dynamic> route) => false);
          }
          else{
           
            throw Exception("Login Failed");
          }
         });
 }
 catch(e){
 signOut(context);
  ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Ops! Login Failed'),
                                  duration: Duration(seconds: 5),
                                ),
                              );
 
 }
 
}

}