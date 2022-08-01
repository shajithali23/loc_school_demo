import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class NannyOpenStreetMapScreen extends StatefulWidget {
  const NannyOpenStreetMapScreen({Key? key}) : super(key: key);

  @override
  State<NannyOpenStreetMapScreen> createState() => _NannyOpenStreetMapScreenState();
}

class _NannyOpenStreetMapScreenState extends State<NannyOpenStreetMapScreen> {
  bool isLoading=false;
  LocationData? _currentLocation;
  late final MapController _mapController;
  final Location _locationService = Location();
  bool _liveUpdate = true;
  bool _permission = false;
  var interActiveFlags = InteractiveFlag.all;
  final _auth = FirebaseAuth.instance;
  late Marker sourceMarker;
  late Marker destinationMarker;
  late List<LatLng> polylines;

  String? _serviceError = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mapController = MapController();
    initLocationService();
   
  }
  loadDataFromFirebase()async{
     var data=await FirebaseFirestore.instance
          .collection("loc")
         .get()
         .then((value) {
          var data= value.docs.first;
   print(data.get("bus_id"));
          GeoPoint current_position = data.get('position');
          GeoPoint start_position = data.get('start_position');
          GeoPoint end_position = data.get('end_position');
          print("route_point");
          print(data.get("route_point"));
          //  polylines=data.get("route");

          sourceMarker=Marker(point: LatLng(start_position.latitude,start_position.longitude), builder: (context)=>Icon(
               Icons.location_pin,
               size: 24,
               color: Colors.green,
             ));
             destinationMarker=Marker(point: LatLng(end_position.latitude,end_position.longitude), builder: (context)=>Icon(
               Icons.location_pin,
               size: 24,
               color: Colors.red,
             ));
         });
  }
void initLocationService() async {
 await loadDataFromFirebase();
    await _locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 100,
    );
           
    LocationData? location;
    bool serviceEnabled;
    bool serviceRequestResult;

    try {
      serviceEnabled = await _locationService.serviceEnabled();

      if (serviceEnabled) {
        var permission = await _locationService.requestPermission();
        _permission = permission == PermissionStatus.granted;

        if (_permission) {
          location = await _locationService.getLocation();
          _currentLocation = location;
          _locationService.onLocationChanged
              .listen((LocationData result) async {
                print(result.latitude);
                print(result.longitude);
                 if(result.latitude!=null){

                 try{

           FirebaseFirestore.instance.collection('loc').doc(_auth.currentUser!.uid).update({'position': GeoPoint(result.latitude!,result.longitude!)});

          }
          catch(e){
            print(e.toString());
          }
                 }
            if (mounted) {
              setState(() {
                _currentLocation = result;

                // If Live Update is enabled, move map center
                if (_liveUpdate) {
                  // _mapController.move(
                  //     LatLng(_currentLocation!.latitude!,
                  //         _currentLocation!.longitude!),
                  //     _mapController.zoom);
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await _locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      if (e.code == 'PERMISSION_DENIED') {
        _serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        _serviceError = e.message;
      }
      location = null;
    }
    setState(() {
     isLoading=true;
      
    });
  }
  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng;
    var needLoadingError = true;


    // Until currentLocation is initially updated, Widget can locate to 0, 0
    // by default or store previous location value to show.
    if (_currentLocation != null) {
      currentLatLng =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    } else {
      currentLatLng = LatLng(0, 0);
    }

     var markers = 
      Marker(
        width: 80.0,
        height: 80.0,
        point: currentLatLng,
        builder: (ctx) => const Icon(
        Icons.pin_drop),
      )
    ;
    return Scaffold(
      body:!isLoading?Center(child: CircularProgressIndicator(),): FlutterMap(
         mapController: _mapController,
                options: MapOptions(
                  center:
                      LatLng(currentLatLng.latitude, currentLatLng.longitude),
                  zoom: 17.0,
                  maxZoom: 18,
                  interactiveFlags: interActiveFlags,
                   onPositionChanged: (MapPosition mapPosition, bool _) {
                      needLoadingError = true;
                    },
                ),
        layers: [
                  TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                    // userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                       errorTileCallback: (Tile tile, error) {
                        if (needLoadingError) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                error.toString(),
                                style: const TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Colors.deepOrange,
                            ));
                          });
                          needLoadingError = false;
                        }
                      },
                  ),
                  //  PolylineLayerOptions(
                  // polylineCulling: true,
                  // polylines: [
                  //     Polyline(
                  //       strokeWidth: 4,
                  //       points: []
                  //       color: Colors.black38,
                  //     ),
                  // ],
                  //     ),
                   MarkerLayerOptions(markers: [sourceMarker,markers,destinationMarker])
                  ]
        ),
    );
  }
}