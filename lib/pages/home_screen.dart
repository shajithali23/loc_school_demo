import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_management_app/map_screen.dart';
import 'package:school_management_app/pages/nanny_map_screen.dart';
import 'package:school_management_app/pages/nanny_osm_map_screen.dart';

import '../cloud/firebase_service.dart';

class HomePage extends StatelessWidget {
   HomePage({Key? key}) : super(key: key);
FirebaseService firebaseService=FirebaseService();
  checkPermission(context)async{
var isEnabled=await Permission.location.serviceStatus.isEnabled;
if(isEnabled){
var status=await Permission.location.status;
  if(status.isGranted){
    navigateToMapScreen(context);
  }
  else if(status.isDenied){
await [Permission.location].request();



  }
}
else{

}
  }
  navigateToMapScreen(context){
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>NannyOpenStreetMapScreen()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Locus"),
        actions: [
          IconButton(onPressed: ()async{
            await firebaseService.signOut(context);
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: Center(child: ElevatedButton(onPressed: ()=>checkPermission(context)
        
//         var isEnabled=await Permission.location.serviceStatus.isEnabled;
//         if(isEnabled){
//           var status=await Permission.location.status;
//           print(status);
//           print("Enabled"+isEnabled.toString());
//           if(status==PermissionStatus.denied){
//             var isPermanentlyDenied= await await Permission.location.isPermanentlyDenied;
//             print(isPermanentlyDenied);
//             print("object");

//             // if(){
//             //   openAppSettings();
//             // }
//             // else{
//             //   print("C");
//             //   openAppSettings();
//             // }
//             Map<Permission,PermissionStatus> statusPermission=await[Permission.location,].request();
//           print(statusPermission);

//             if(status==PermissionStatus.granted){
//             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MapScreen()));

//           }
//           }
//           else if(status==PermissionStatus.permanentlyDenied){
// print("PERMANT Denied");
// openAppSettings();
//           }
//           else{
//             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MapScreen()));
//           }


//           if(status==PermissionStatus.granted){
//             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MapScreen()));

//           }

//         }
//         else{
//           print("Disabled");
//         }

      // }
      , child: Text("Trip Start")),),
    );
  }
}