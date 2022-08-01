import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NannyMapScreen extends StatefulWidget {
  const NannyMapScreen({Key? key}) : super(key: key);

  @override
  State<NannyMapScreen> createState() => _NannyMapScreenState();
}

class _NannyMapScreenState extends State<NannyMapScreen> {
   LatLng initialPosition=LatLng(0.0, 0.0);
    // late BitmapDescriptor schoolBitmap;
    Set<Marker> markerData = Set();
     final _auth = FirebaseAuth.instance;
     GoogleMapController? mapController;
 PolylinePoints polylinePoints = PolylinePoints();
 List<LatLng> polylineCoordinates = [];
 Map<PolylineId, Polyline> polylines = {};


   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
  }
  addPolyLine(List<LatLng> polylineCoordinates) {
  PolylineId id = PolylineId("poly");
  Polyline polyline = Polyline(
    polylineId: id,
    color: Colors.deepPurpleAccent,
    points: polylineCoordinates,
    width: 8,
  );
  polylines[id] = polyline;
  setState(() {
    polylines;
  });
}
  getCurrentLocation()async{
    PointLatLng i=PointLatLng(11.1088138,77.3507118);
    PointLatLng e=PointLatLng(11.10451519931877, 77.3480262237446);
    String googleAPiKey="AIzaSyDYTLvZWE49ZuM69QPu4LMDJJoybazvMOA";
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(googleAPiKey, i,e,travelMode: TravelMode.driving);
if (result.points.isNotEmpty) {
  print("WWWWWWWWWWWWWWWWWWWWWWWWW");
      result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
} else {
  print("no");
    print(result.errorMessage);
}
addPolyLine(polylineCoordinates);

var geolocator = Geolocator();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 0,
);
StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
    (Position? position) {
        print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
        if(position!=null){
          try{
           FirebaseFirestore.instance.collection('loc').doc(_auth.currentUser!.uid).update({'position': GeoPoint(position.latitude,position.longitude)});

          }
          catch(e){
            print(e.toString());
          }
          // initialPosition=LatLng(position.latitude,position.longitude);
            mapController?.animateCamera( 
        CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(position.latitude,position.longitude), zoom: 14.4746) 
              //17 is new zoom level
        )
      );
              markerData.add(Marker(
      markerId: MarkerId("Current Location"),
      position: LatLng(position.latitude,position.longitude),
      infoWindow: InfoWindow(title: "Bus Location", ),
      icon: BitmapDescriptor.defaultMarkerWithHue(0.0),
      
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    ));
//  _getPolyline(pos,endPos);
  //   kGooglePlex = CameraPosition(
  //   target: LatLng(11.107950, 77.340683),
  //   zoom: 14.4746,
  // );
        }
        else{
          // latitude=0.0;
          // longitude=0.0;
        
        }
        setState(() {
          // latitude;
          // longitude;
          markerData;
          initialPosition;
        });
    });

  }
 getLocation()async{

  // await loadBitMapIcon();
 await getCurrentLocation();
var collection = FirebaseFirestore.instance.collection('loc');
     var docSnapshot = await collection.doc(_auth.currentUser!.uid).get();
Map<String, dynamic>? data = docSnapshot.data();
GeoPoint start_position = data!['start_position'];
GeoPoint end_position = data['end_position'];
addMarker(start_position, BitmapDescriptor.defaultMarkerWithHue(30),"Source");
addMarker(end_position, BitmapDescriptor.defaultMarkerWithHue(180), "Destination");

setState(() {
  markerData;
});


 }
 addMarker(position,bitmapDescriptor,id){
     markerData.add(Marker(
      markerId: MarkerId(id),
      position: LatLng(position.latitude,position.longitude),
      infoWindow: InfoWindow(title: id,),
      icon: bitmapDescriptor,
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    ));

 }
//  loadBitMapIcon()async{
//     schoolBitmap = await BitmapDescriptor.fromAssetImage(
//     ImageConfiguration(size: Size(18,18)),
//     "assets/icons/school.png",
// );
//  }
 @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.terrain,
              polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (controller) { 
            setState(() {
              mapController = controller; 
            });
      },
              markers: markerData,initialCameraPosition: CameraPosition(target: initialPosition,zoom: 14.4746)),
      //   DraggableScrollableSheet(
      //      initialChildSize: 0.3,
      // minChildSize: 0.3,
      // maxChildSize: 0.9,
      // builder: (BuildContext context, myScrollController) {
      //   return Container(
      //     color: Colors.red,
      //     child: ListView(
      //       controller: myScrollController,
      //       shrinkWrap: true,
      //       children:List.generate(25, (index) => Text(index.toString())),
      //     ),
      //   );
      // }
      //   )
        
          ],
        ),
      ),
    );
  }
}