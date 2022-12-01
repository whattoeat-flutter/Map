import 'dart:async';
import 'dart:collection';
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
    //근처 식당 10개 받아온다
    //받아온 respoonse값은 parsing 함수에서 처리한다
      //1. 서버로 id 전달
      //2. 마커 생성(몇 개?)
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
    Map result_map = {};
    List result = dataConvertedToJSON["documents"];
    result= result.sublist(0,10);
    //카카오에서 받아온 카페정보 10개에 대해, id가 key값이 되도록 맵(result_map) 생성
    for (int i = 0; i<result.length;i++){
      result_map.addAll({result[i]['id']: result[i]});
    }

    //id를 서버로 넘김
    send2server(result_map);

    //마커 추가
    make_marker_list(result_map);

  }

  send2server(Map data_kko) async {
    List<String> id_list=[];

    data_kko.forEach((key, value) {
      id_list.add(key.toString());
    });

    Map request_id = {
      'ids' : id_list
    };

    var body_id = json.encode(request_id);
    //string맞는지 확인 부탁드립니다.
    String str_url_server='http://35.243.115.214:8080/parse/';
    var url_server = Uri.parse(str_url_server);
    http.Response response_server = await http.post(
      url_server,
      headers: //<String, String>
      {
        'Content-Type': 'application/json',
      },
      body: body_id
    );

    var responseBody = utf8.decode(response_server.bodyBytes);
    var dataConvertedToJSON_server = jsonDecode(responseBody);//json.utf8.decode(response_server.body);
    send2choosing(dataConvertedToJSON_server, data_kko);
    //basemappage로 넘어감
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BaseMapPage(pos: widget.pos, markers: _markers,),
      ),
    );
  }
  //파싱함수
  send2choosing(var dataConvertedToJSON_server, Map data_kko){
    List<Map> shop_list = [];

    dataConvertedToJSON_server.forEach((key, value) {
      Map shop = {};
      Map kakao={};
      Map shop_value = {};
      //id
      shop['id']=key;
      //name kko
      //서버에서 받아온 id와 일치하는 id를 가진 kakao_response
      kakao = data_kko[key];
      shop['name'] = kakao['place_name'];
      //category kko
      shop['category'] = kakao['category_name'];
      //phonenum
      shop['phonenum'] = value['phone'].toString();
      //address
      shop['address']  = value['address'].toString();
      //locX kko
      shop['locX'] = kakao['x'];
      //locY kko
      shop['locY'] = kakao['y'];
      //placeUrl
      shop['placeUrl'] = value['picture'].toString();
      //menulist
      Map menu = {};
      List menulist=[];
      List menuprices=[];
      menu = value['menus'];
      if(menu.length > 0){
        menu.forEach((key, value) {
          menulist.add(key);
          menuprices.add(value);
        });
      }else{
        print("\'menus\' is empty.");
      }
      shop['menulist'] = menulist;
      shop['menuprices'] = menuprices;

      //menuprices
      //review_count
      shop['review_count']  = int.parse(value['number_of_ratings']);
      //rating
      shop['rating']  = double.parse(value['number_of_ratings']);
      //distance
      //avg_price
      //max_price
      //shop['menulist']=value[0].value; //메뉴가 null인 경우?
      /*shop_value=value;
      List<Map> value_list = [];
      value_list.add(shop_value);*/

      shop_list.add(shop);
    });
    print("");
    /*for(int i = 0 ; i<dataConvertedToJSON_server.length; i++){
      Map shop = {};
      Map temp = dataConvertedToJSON_server[i];
      //shop['id']=.keys;
      print("");
    }*/
    
  }
  make_marker_list(Map data_kko){
    data_kko.forEach((key, value) {
      _markers.add(Marker(
        markerId: DateTime.now().toIso8601String(),
        position: LatLng(double.parse(value['y']), double.parse(value['x'])),//pos_marker,
        infoWindow: '테스트',
        //onMarkerTab: _onMarkerTap,
      ));
    });


    /*for(int i = 0;i<data.length;i++){
      _markers.add(Marker(
        markerId: DateTime.now().toIso8601String(),
        position: LatLng(double.parse(data[i]['y']), double.parse(data[i]['x'])),//pos_marker,
        infoWindow: '테스트$i',
        //onMarkerTab: _onMarkerTap,
      ));
    }*/
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


}

