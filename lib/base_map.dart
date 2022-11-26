import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';

//사용자 현재 위치
import 'package:geolocator/geolocator.dart';
//url
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class BaseMapPage extends StatefulWidget {
  const BaseMapPage({super.key, required this.pos, required this.markers});

  final Position pos;
  final List<Marker> markers;
  @override
  _BaseMapPageState createState() => _BaseMapPageState();
}

class _BaseMapPageState extends State<BaseMapPage> {
  //marker mode
  static const MODE_ADD = 0xF1;
  static const MODE_REMOVE = 0xF2;
  static const MODE_NONE = 0xF3;
  int _currentMode = MODE_NONE;
  Completer<NaverMapController> _controller = Completer(); //이게 뭐지
  //List<Marker> _markers = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<NaverMapController> _coe = Completer();

  MapType _mapType = MapType.Basic;
  LocationTrackingMode _trackingMode = LocationTrackingMode.NoFollow;

  @override
  void initState() {
    //searchID(widget.pos);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OverlayImage.fromAssetImage(
          assetName: './icon/marker.png',

      );
    });

    super.initState();
  }

  /*searchID(Position w_pos) async {
    int page=1;
    String str_url_1="https://dapi.kakao.com/v2/local/search/category.json?" +
        "category_group_code=FD6"+
        "&page="+page.toString()+
        "&size=15&sort=distance"+
        "&y="+w_pos.latitude.toString()+
        "&x="+w_pos.longitude.toString()
    ;
    page++;
    String str_url_2="https://dapi.kakao.com/v2/local/search/category.json?" +
        "category_group_code=FD6"+
        "&page="+page.toString()+
        "&size=15&sort=distance"+
        "&y="+w_pos.latitude.toString()+
        "&x="+w_pos.longitude.toString()
    ;
    String API_key="KakaoAK d73a05d9aa0d601170d3de05ae441263";

    var url = Uri.parse(str_url_1);
    var response_1 = await http.get(url, headers: {"Authorization": API_key});

    parsing(response_1);

    var url_2 = Uri.parse(str_url_2);
    var response_2 = await http.get(url_2, headers: {"Authorization": API_key});

    parsing(response_2);
    //print(response.body);
    //HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
  }

  parsing(var response_json){
    List data = [];
    var dataConvertedToJSON = json.decode(response_json.body);
    List result = dataConvertedToJSON["documents"];
    data.addAll(result);

    String test;
    test=data[0]['id'].toString();
    //rest api로 받아온 값을 마커에 저장
    for(int i = 0;i<data.length;i++){
      //LatLng pos_marker = LatLng(double.parse(data[i]['x']), double.parse(data[i]['y']));
      _markers.add(Marker(
        markerId: DateTime.now().toIso8601String(),
        position: LatLng(double.parse(data[i]['y']), double.parse(data[i]['x'])),//pos_marker,
        infoWindow: '테스트$i',
        //onMarkerTab: _onMarkerTap,
      ));
    }
    print(test);
  }*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          _naverMap(),
          _controlPanel(),
        ],
      ),
    );
  }

  _controlPanel(){
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentMode = MODE_ADD),
                child: Container(
                  decoration: BoxDecoration(
                      color:
                      _currentMode == MODE_ADD ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black)),
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(right: 8),
                  child: Text(
                    '추가',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                      _currentMode == MODE_ADD ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }
  _naverMap(){
    return Expanded(
        child: Stack(
          children: <Widget>[
            /*NaverMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(37.566570, 126.978442),
                zoom: 17,
              ),
              onMapCreated: onMapCreated,
              //mapType: _mapType,
              //initLocationTrackingMode: _trackingMode,
              locationButtonEnable: true,
              indoorEnable: true,
              //onCameraChange: _onCameraChange,
              //onCameraIdle: _onCameraIdle,
              onMapTap: _onMapTap,
              //onMapLongTap: _onMapLongTap,
              //onMapDoubleTap: _onMapDoubleTap,
              //onMapTwoFingerTap: _onMapTwoFingerTap,
              //onSymbolTap: _onSymbolTap,
              maxZoom: 17,
              minZoom: 15,
            ),*/
            NaverMap(
              //첫 화면 표시 위치
              initialCameraPosition: CameraPosition(
                //현재 위치
                target: LatLng(widget.pos.latitude, widget.pos.longitude),
                zoom: 14,
              ),
              //위치 버튼
              locationButtonEnable: true,
              indoorEnable: true,
              markers: widget.markers,
              onMapTap: _onMapTap,
              onMapCreated: onMapCreated,
              /*
            initLocationTrackingMode: _trackingMode,
            onCameraChange: _onCameraChange,
            onCameraIdle: _onCameraIdle,
            //mapType: _mapType,
            //위도경도 알려줌
            //
            //onMapLongTap: _onMapLongTap,
            //onMapDoubleTap: _onMapDoubleTap,
            //onMapTwoFingerTap: _onMapTwoFingerTap,
            //onSymbolTap: _onSymbolTap,
            //maxZoom: 17,
            //minZoom: 15,*/
            ),
          ],
        )
    );
  }

  _onMapTap(LatLng position) async {
    /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
      Text('[onTap] lat: ${position.latitude}, lon: ${position.longitude}'),
      duration: Duration(milliseconds: 500),
      backgroundColor: Colors.black,
    ));*/
    if (_currentMode == MODE_ADD) {

      /*_markers.add(Marker(
        markerId: DateTime.now().toIso8601String(),
        position: position,
        infoWindow: '테스트',
        //onMarkerTab: _onMarkerTap,
      ));
      setState(() {
        print("addmarker");
      });*/
    }
  }



  void onMapCreated(NaverMapController controller) {
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
  }
}

