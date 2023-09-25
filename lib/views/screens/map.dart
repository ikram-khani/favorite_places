import 'dart:async';

import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.22,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;
  var _isGettingLocation = false;
  @override
  void initState() {
    super.initState();
    //if it is selecting then get the usercurrent location in the initstate
    if (widget.isSelecting) {
      _getCurrentUserLocation();
    }
  }

//get current location for the map
  Future<void> _getCurrentUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    //showing loading spinner during fetching current location
    setState(() {
      _isGettingLocation = true;
    });

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    setState(() {
      _pickedLocation = LatLng(lat, lng);
      _isGettingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
              icon: const Icon(Icons.save),
            ),
        ],
      ),
      //show progressIndicator while fetching the current location
      body: _isGettingLocation
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              onTap: !widget.isSelecting
                  ? null
                  : (position) {
                      setState(() {
                        _pickedLocation = position;
                      });
                    },
              //in detail screen the _pickedLocation will be null from getCurrentLocation cz in initstate the isSelecting will be false and also in onTap it will be null so we will see the already save location
              initialCameraPosition: CameraPosition(
                target: _pickedLocation ??
                    LatLng(
                      widget.location.latitude,
                      widget.location.longitude,
                    ),
                zoom: 16,
              ),
              markers: (_pickedLocation == null && widget.isSelecting)
                  ? {}
                  : {
                      Marker(
                        markerId: const MarkerId('m1'),

                        //also can use this syntax (_pickedLocation??LatLng(widget.location.latitude,widget.location.longitude))

                        position: _pickedLocation != null
                            ? _pickedLocation!
                            : LatLng(
                                widget.location.latitude,
                                widget.location.longitude,
                              ),
                      ),
                    },
            ),
    );
  }
}
