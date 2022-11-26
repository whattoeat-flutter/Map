import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:naver_map_plugin/naver_map_plugin.dart';
import './base_map.dart';
//사용자 현재 위치
import 'package:geolocator/geolocator.dart';
//url
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestAPIPage extends StatefulWidget {
  const RestAPIPage({super.key, required this.pos});
  final Position pos;
  @override
  _RestAPIState createState() => _RestAPIState();
}

class _RestAPIState extends State<RestAPIPage> {
  List<Marker> _markers = [];

  final scaffoldKey = GlobalKey<ScaffoldState>();
  void initState() {
    //근처 식당 15개 받아온다
    searchID(widget.pos);
    super.initState();
  }

  searchID(Position w_pos) async {
    int page=1;
    String str_url_1="https://dapi.kakao.com/v2/local/search/category.json?" +
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

  }

  parsing(var response_json){
    List data = [];
    var dataConvertedToJSON = json.decode(response_json.body);
    List result = dataConvertedToJSON["documents"];
    data.addAll(result);

    //id를 서버로 넘김
    send2server(data);

    //마커 추가
    make_marker_list(data);

  }

  send2server(List data_id) async {
    List<String> id_list=[];
    for(int i=0;i<data_id.length;i++) {
      id_list.add(data_id[i]["id"].toString());
    }

    Map request_id = {
      'ids' : id_list
    };

    var body_id = json.encode(request_id);
    //string맞는지 확인 부탁드립니다.
    String str_url_server='http://35.243.115.214:8080/parse/';
    var url_server = Uri.parse(str_url_server);
    http.Response response_id = await http.post(
      url_server,
      headers: //<String, String>
      {
        'Content-Type': 'application/json',
      },
      body: body_id
    );


    //basemappage로 넘어감
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BaseMapPage(pos: widget.pos, markers: _markers,),
      ),
    );
  }
  make_marker_list(List data){
    for(int i = 0;i<data.length;i++){
      _markers.add(Marker(
        markerId: DateTime.now().toIso8601String(),
        position: LatLng(double.parse(data[i]['y']), double.parse(data[i]['x'])),//pos_marker,
        infoWindow: '테스트$i',
        //onMarkerTab: _onMarkerTap,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


}

