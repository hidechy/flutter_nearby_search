import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/nearby_places_response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String apiKey = 'AIzaSyD9PkTM1Pur3YzmO-v4VzS0r8ZZ0jRJTIU';

  String radius = '1000';

  late double latitude;
  late double longitude;

  NearbyPlacesResponse nearbyPlacesResponse = NearbyPlacesResponse();

  ///
  @override
  void initState() {
    super.initState();

    getPosition();
  }

  ///
  Future<void> getPosition() async {
    final currentPosition = await _determinePosition();

    latitude = currentPosition.latitude;
    longitude = currentPosition.longitude;
  }

  ///
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                getNearbyPlaces();
              },
              child: const Text('nearby'),
            ),
            if (nearbyPlacesResponse.results != null)
              for (var i = 0; i < nearbyPlacesResponse.results!.length; i++)
                nearbyPlacesWidget(data: nearbyPlacesResponse.results![i]),
          ],
        ),
      ),
    );
  }

  ///
  void getNearbyPlaces() async {
    var mapUrl = [];
    mapUrl.add('https://maps.googleapis.com/maps/api/place/nearbysearch/json');
    mapUrl.add('?location=$latitude,$longitude');
    mapUrl.add('&radius=$radius');
    mapUrl.add('&key=$apiKey');

//    mapUrl.add('&keyword=公園OR広場OR駅');
//    mapUrl.add('&keyword=駅');
    mapUrl.add('&keyword=お手洗い');

    var url = Uri.parse(mapUrl.join());

    var response = await http.post(url);

    nearbyPlacesResponse = NearbyPlacesResponse.fromJson(
      jsonDecode(response.body),
    );

    setState(() {});
  }

  Widget nearbyPlacesWidget({required Results data}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${data.name}'),
          Text(
            'Location: ${data.geometry!.location!.lat} / ${data.geometry!.location!.lng}',
          ),
          Text(data.openingHours != null ? "Open" : "Close"),
        ],
      ),
    );
  }
}
