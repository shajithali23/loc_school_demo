import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
   late bool _serviceEnabled;
   double latitude=0.0;
   double longitude=0.0;
 
  // LocationData? _userLocation;
   Set<Marker> markerData = Set();
 
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(11.107950, 77.340683),
    zoom: 14.4746,
  );
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyDYTLvZWE49ZuM69QPu4LMDJJoybazvMOA";


// Future<void> _getUserLocation() async {
//     Location location = Location();

//     // Check if location service is enable
//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     // Check if permission is granted
//     // _permissionGranted = await location.hasPermission();
//     // if (_permissionGranted == PermissionStatus.denied) {
//     //   _permissionGranted = await location.requestPermission();
//     //   if (_permissionGranted != PermissionStatus.granted) {
//     //     return;
//     //   }
//     // }
//      var geolocator = Geolocator();
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


//     // ignore: unused_local_variable
//     // ignore: cancel_subscriptions
//     StreamSubscription<Position> positionStream = geolocator
//         .getPositionStream(locationOptions)
//         .listen((Position position) {
//       setState(() {
//         print(position == null
//             ? 'Unknown'
//             : position.latitude.toString() +
//                 ', ' +
//                 position.longitude.toString());
//         _locationMessage =
//             "${position.latitude.toString()}, ${position.longitude.toString()}";

//         //String hoa = positionStream;
//       });
//     });

//     final _locationData = await location.getLocation();
//     markerData.add(Marker(
//       markerId: MarkerId("Current Location"),
//       position: LatLng(_locationData.latitude!.toDouble(), _locationData.longitude!.toDouble()),
//       infoWindow: InfoWindow(title: "Bus Location", snippet: '*'),
//       onTap: () {
//         // _onMarkerTapped(markerId);
//       },
//     ));
//   //   kGooglePlex = CameraPosition(
//   //   target: LatLng(11.107950, 77.340683),
//   //   zoom: 14.4746,
//   // );
//     setState(() {
//       _userLocation = _locationData;
//       markerData;
//     });
//   }
 
 
 getLocation()async{
  BitmapDescriptor schoolBitmap = await BitmapDescriptor.fromAssetImage(
    ImageConfiguration(size: Size(50,50)),
    "assets/icons/education.png",
);
 BitmapDescriptor curentLocation = await BitmapDescriptor.fromAssetImage(
    ImageConfiguration(size: Size(50,50)),
    "assets/icons/bus.png",
);

 
   var collection = FirebaseFirestore.instance.collection('loc');
     final _auth = FirebaseAuth.instance;
 
 
var docSnapshot = await collection.doc(_auth.currentUser!.uid).get();
Map<String, dynamic>? data = docSnapshot.data();
print(data!["bus_id"]);
GeoPoint pos = data['start_position'];
GeoPoint endPos = data['end_position'];
markerData.add(Marker(
      markerId: MarkerId(data["bus_id"]),
      position: LatLng(pos.latitude, pos.longitude),
      infoWindow: InfoWindow(title: data["bus_id"], snippet: '*'),
      icon: schoolBitmap,
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    ));
         markerData.add(Marker(
      markerId: MarkerId("DDD"),
      position: LatLng(endPos.latitude, endPos.longitude),
      infoWindow: InfoWindow(title: data["bus_id"], snippet: '*'),
      icon: schoolBitmap,
      onTap: () {
        // _onMarkerTapped(markerId);
      },
    )); 
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
           FirebaseFirestore.instance.collection('loc').doc(_auth.currentUser!.uid).update({'position': GeoPoint(position.latitude,position.longitude)});
          latitude=position.latitude;
          longitude=position.longitude;
              markerData.add(Marker(
      markerId: MarkerId("Current Location"),
      position: LatLng(position.latitude,position.longitude),
      infoWindow: InfoWindow(title: "Bus Location", snippet: '*'),
      icon: curentLocation,
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
          latitude=0.0;
          longitude=0.0;
        
        }
        setState(() {
          latitude;
          longitude;
          markerData;
        });
    });
// StreamSubscription<Position> positionStream = geolocator
//         .getPositionStream(locationOptions)
//         .listen((Position position) {
//       setState(() {
//         print(position == null
//             ? 'Unknown'
//             : position.latitude.toString() +
//                 ', ' +
//                 position.longitude.toString());
//         _locationMessage =
//             "${position.latitude.toString()}, ${position.longitude.toString()}";

//         //String hoa = positionStream;
//       });
//     });

 }
 _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline(pos2,pos3) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
         PointLatLng(pos2.latitude,pos2.longitude),
        PointLatLng(pos3.latitude,pos3.longitude),
        // PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      
    }
    else{
      print(result.errorMessage);
      print("NO POINTS");
    }
    _addPolyLine();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _getUserLocation();
   
getLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.amber,
      body: Center(child:  latitude!=0.0
                ? GoogleMap(
                  markers: markerData,
                  polylines: Set<Polyline>.of(polylines.values),
                  // onMapCreated: (GoogleMapController controller) {
                  //   _controller.complete(controller);
                  // },
                  initialCameraPosition: _kGooglePlex,
                )
                :CircularProgressIndicator(),),
    );
  }
}