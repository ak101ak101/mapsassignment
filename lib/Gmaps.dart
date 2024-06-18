import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert' as convert;
import 'location/location_bloc.dart';

class GoogleMapsPage extends StatefulWidget {
  const GoogleMapsPage({super.key});

  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {


  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = {}; //
@override
void initState(){
  context.read<LocationBloc>().add(currentlocationevent());
}

  Future<void> getNearbyHospitals() async {
    // Get the user's current location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Define the API endpoint and parameters
    const apiKey = 'AIzaSyD0xKuDCJV_vwrhH6b5pWdcDdbwmpydvns';
    final endpoint = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/nearbysearch/json',
      {
        'key': apiKey,
        'location': '${position.latitude},${position.longitude}',
        'radius': '6000', // Search within a 5 km radius
        'type': 'hospital',
      },
    );

    // Make the HTTP request
    final response = await http.get(endpoint);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final results = data['results'] as List;

      // Create markers for the nearby hospitals
      final hospitalMarkers = results.map((place) {
        final geometry = place['geometry']['location'];
        final latLng = LatLng(geometry['lat'], geometry['lng']);
        return Marker(
          markerId: MarkerId(place['place_id']),
          position: latLng,
          infoWindow: InfoWindow(
            title: place['name'],
            snippet: place['vicinity'],
          ),
        );
      }).toList();

      // Add the hospital markers to the map
      setState(() {
        markers.addAll(hospitalMarkers);
      });
    } else {
      // Handle the API request error
      print('Failed to fetch nearby hospitals');
    }
  }
  // void _onMapCreated(GoogleMapController controller) {
  //    // mapController = _controller;
  //   getNearbyHospitals();
  //   // Add any additional map setup or customization here
  // }
  @override
  Widget build(BuildContext context) {
    return   BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is currentLocationstate) {
          print(state.position.latitude);
          print(state.position.longitude);
        }
        // TODO: implement listener
      },
      builder: (context, state) {
        if (state is currentLocationstate) {
          LatLng finallocation =
          LatLng(state.position.latitude, state.position.longitude);
          return Stack(
            children: [
              GoogleMap(
                // onMapCreated: _onMapCreated,
                minMaxZoomPreference: MinMaxZoomPreference(12, 20),
                onCameraIdle: () {
                  // context.read<CureentlocationBloc>().add(
                  //     taplocationevent(finallocation.latitude,
                  //         finallocation.longitude));
                },
                onCameraMove: (CameraPosition c) {
                  finallocation = c.target;
                },
                myLocationEnabled: true,
                onTap: (LatLng latLng) {
                  var lat = latLng.latitude;
                  var long = latLng.longitude;
                  // context
                  //     .read<CureentlocationBloc>()
                  //     .add(taplocationevent(lat, long));
                },
                markers: {
                  ...markers,
                  Marker(
                    markerId: const MarkerId("marker1"),
                    position: LatLng(state.position.latitude,
                        state.position.longitude),
                    draggable: true,
                    onDragEnd: (value) {
                      print(value.latitude.toString() +
                          value.longitude.toString() +
                          "values");
                      // context.read<CureentlocationBloc>().add(
                      //     taplocationevent(
                      //         value.latitude, value.latitude));
                      // value is the new position
                    },
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                  // Marker(
                  //   markerId: const MarkerId("marker2"),
                  //   position:
                  //       const LatLng(37.415768808487435, -122.08440050482749),
                  // ),
                },
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                    target: LatLng(state.position.latitude,
                        state.position.longitude),
                    zoom: 12),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  print("animating");
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: LatLng(state.position.latitude,
                              state.position.longitude),
                          zoom: 12)));
                  getNearbyHospitals();
                  //
                  // showLocation(context, controller);
                  // _onMarkerTapped();
                  // _controller.complete(controller);
                  // controller.showMarkerInfoWindow(MarkerId("maker2"));
                },
              ),

            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
