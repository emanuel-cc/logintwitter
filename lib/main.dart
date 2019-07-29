import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
//Twitter provider
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

 
void main() => runApp(MyApp());
 
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLooged = false;
  FirebaseUser _user;
  String _message = 'Logged out.';

  //Twitter Sign In
  var twitterLogin = new TwitterLogin(
      consumerKey: '',
      consumerSecret: ''
    );

  void _loginWithTwitter() async{
    
    final TwitterLoginResult twitterLoginResult = await twitterLogin.authorize();
    String newMessage;
    switch(twitterLoginResult.status){
      case TwitterLoginStatus.loggedIn:
        var session = twitterLoginResult.session;
        final token = twitterLoginResult.session.token;
        final credential = TwitterAuthProvider.getCredential(
          authToken: token,
          authTokenSecret: session.secret
        );
         //_user = await _auth.signInWithCredential(credential);
        //return _user;
        //newMessage = 'Logged in! username: ${twitterLoginResult.session.username}';
        break;
      case TwitterLoginStatus.cancelledByUser:
        debugPrint(twitterLoginResult.status.toString());
        newMessage = 'Login cancelled by user.';
        break;
      case TwitterLoginStatus.error:
        debugPrint(twitterLoginResult.errorMessage.toString());
        newMessage = 'Login error: ${twitterLoginResult.errorMessage}';
        break;
    }
    //return _user;

    /*setState(() {
      _message = newMessage;
    });*/
   

    
  }
  /*void _logInTwitter(){
      _loginWithTwitter().then((response){
        if(response!=null){
          _user = response;
          isLooged = true;
          setState(() {
            
          });
        }
      });
  }*/
  void _logout()async{
      await twitterLogin.logOut().then((response){
        isLooged = false;
      });
      setState(() {
        _message = 'Logged out.';
      });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text(isLooged ? "Profile Page" : "Facebook Login"),
          actions: <Widget>[
            isLooged ? IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: _logout,
            ) : IconButton(
              icon: Icon(Icons.remove_red_eye),
              onPressed: (){},
            )
          ],
        ),
        body: Center(
          child: isLooged ?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Name: '+ _user.displayName),
              Image.network(_user.photoUrl),
            ],
          )
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TwitterSignInButton(
                onPressed: _loginWithTwitter,
              )
            ],
          )
        ),
      ),
    );
  }
}