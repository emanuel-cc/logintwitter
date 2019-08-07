import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/services.dart';
//Twitter provider
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
//import 'package:flutter_twitter/flutter_twitter.dart';

 
void main() => runApp(MyApp());
 
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLooged = false;
  FirebaseUser _user;

  //Twitter Sign In
  var twitterLogin = new TwitterLogin(
      consumerKey: 'b9CMf0NhNm7upSbDuxuj22jGI',
      consumerSecret: 'ij17XQkSX8QXov8HUIJvfd1nSem4TaSO5mYmUD5GNwOhRbOD8k'
    );

    String _message = 'Logged out.';

  Future<FirebaseUser> _loginWithTwitter() async {
    
    final TwitterLoginResult twitterLoginResult = await twitterLogin.authorize();
    String newMessage;
    switch(twitterLoginResult.status){
      case TwitterLoginStatus.loggedIn:
        var session = twitterLoginResult.session;
        //final token = twitterLoginResult.session.token;
        final AuthCredential credential = TwitterAuthProvider.getCredential(
          authToken: session.token,
          authTokenSecret: session.secret
        );
          _user = await _auth.signInWithCredential(credential);
        //return _user;
        
        newMessage = 'Logged in! username: ${twitterLoginResult.session.username}';
        break;
      case TwitterLoginStatus.cancelledByUser:
        debugPrint(twitterLoginResult.status.toString());
        newMessage = 'Login cancelled by user.';
        print(newMessage);
        break;
      case TwitterLoginStatus.error:
        debugPrint(twitterLoginResult.errorMessage.toString());
        newMessage = 'Login error: ${twitterLoginResult.errorMessage}';
        print(newMessage);
        break;
    }
    return _user;

    /*setState(() {
      //_message = newMessage;
    });*/
   

    
  }
  
  void _logout()async{
      await twitterLogin.logOut().then((response){
        isLooged = false;
      });
      _auth.signOut().then((response){
        isLooged=false;
      });
    
      setState(() {
       print(_message);
      });
  }

  void _logInTwitter(){
      _loginWithTwitter().then((response){
        if(response!=null){
          
          setState(() {
            _user = response;
          isLooged = true;
          });
        }
      });
  }
  @override
  Widget build(BuildContext context) {
    dynamic email;
    email = _user.providerData.map((pro)=>pro.email);
    print('${_user.providerData.map((pro)=>pro.email)}');
    
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text(isLooged ? "Profile Page" : "Twitter Login"),
          actions: <Widget>[
            isLooged ? IconButton(
              icon: Icon(Icons.power_settings_new),
              onPressed: (){
                _logout();
                },
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
              //Text(_user.providerData.toString()),
              Text(email.toString()),
              //Text(_user.phoneNumber.toString()),
              Image.network(_user.photoUrl)
            ],
          )
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TwitterSignInButton(
                onPressed: (){
                  _logInTwitter();
                  //_loginWithTwitter().then((FirebaseUser user)=>print('Su correo es ${user.email}'));
                  },
              )
            ],
          )
        ),
      ),
    );
  }
}