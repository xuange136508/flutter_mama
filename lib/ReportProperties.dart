/// os : "android"
/// user_tr : "PVk8NxtNr79eNA7BdsK5ZbHYljFP7xoqg9zbuAvDKx8GvSPbZpDO6cnR4rDf1vrLpYXFcUv4fWrjLqPaFsulIR%2Fcum6lVfZnSy6wyDJSzMdKJ1nVo6P7U8onn9Om%2FzdlZtIIWS2errSirYRFK1Tu2n6HbKW2YCBYouWEXoGqtvuKKvcbuvRc3ZxIw1v0t8psx6StFf2cOs6R8cKmMu21aNF6umGbSnK5xequD6yEJtm6ilMwCQJAgINtXYl8Td4rP14ukzbTWrXILHRSbCoiEqOhRB%2Be2aEFhueP8DBC3n5j%2BNNC%2BR2Ntf4pIrLmSqkN"
/// event : "duration"
/// content : {"app":"pt","search_keyword":"","app_ver":"12.9.0","action":"","context_type":"","contextid":""}
/// properties : [{"itemid":"-1","item_mark":"{\"item_mark_9\":\"1663756024\",\"item_name\":\"cn.mama.pregnant.module.discovery.NewDiscoveryFragment\",\"item_mark_1\":\"1663756035\",\"item_mark_2\":\"1663756048\"}","item_type":"pt_os","close_reason":"","position":"pagetime","sessionid":"f71db5e7","time":"1663756048998"}]

class ReportProperties {

  ReportProperties.fromJson(dynamic json) {
    _os = json['os'];
    _userTr = json['user_tr'];
    _event = json['event'];
    _content = json['content'] != null ? Content.fromJson(json['content']) : null;
    if (json['properties'] != null) {
      _properties = [];
      json['properties'].forEach((v) {
        _properties?.add(Properties.fromJson(v));
      });
    }
  }
  String? _os;
  String? _userTr;
  String? _event;
  Content? _content;
  List<Properties>? _properties;

  String? get os => _os;
  String? get userTr => _userTr;
  String? get event => _event;
  Content? get content => _content;
  List<Properties>? get properties => _properties;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['os'] = _os;
    map['user_tr'] = _userTr;
    map['event'] = _event;
    if (_content != null) {
      map['content'] = _content?.toJson();
    }
    if (_properties != null) {
      map['properties'] = _properties?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// itemid : "-1"
/// item_mark : "{\"item_mark_9\":\"1663756024\",\"item_name\":\"cn.mama.pregnant.module.discovery.NewDiscoveryFragment\",\"item_mark_1\":\"1663756035\",\"item_mark_2\":\"1663756048\"}"
/// item_type : "pt_os"
/// close_reason : ""
/// position : "pagetime"
/// sessionid : "f71db5e7"
/// time : "1663756048998"

class Properties {

  Properties.fromJson(dynamic json) {
    _itemid = json['itemid'];
    _itemMark = json['item_mark'];
    _itemType = json['item_type'];
    _closeReason = json['close_reason'];
    _position = json['position'];
    _sessionid = json['sessionid'];
    _time = json['time'];
  }
  String? _itemid;
  String? _itemMark;
  String? _itemType;
  String? _closeReason;
  String? _position;
  String? _sessionid;
  String? _time;

  String? get itemid => _itemid;
  String? get itemMark => _itemMark;
  String? get itemType => _itemType;
  String? get closeReason => _closeReason;
  String? get position => _position;
  String? get sessionid => _sessionid;
  String? get time => _time;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['itemid'] = _itemid;
    map['item_mark'] = _itemMark;
    map['item_type'] = _itemType;
    map['close_reason'] = _closeReason;
    map['position'] = _position;
    map['sessionid'] = _sessionid;
    map['time'] = _time;
    return map;
  }

}

/// app : "pt"
/// search_keyword : ""
/// app_ver : "12.9.0"
/// action : ""
/// context_type : ""
/// contextid : ""

class Content {

  Content.fromJson(dynamic json) {
    _app = json['app'];
    _searchKeyword = json['search_keyword'];
    _appVer = json['app_ver'];
    _action = json['action'];
    _contextType = json['context_type'];
    _contextid = json['contextid'];
  }
  String? _app;
  String? _searchKeyword;
  String? _appVer;
  String? _action;
  String? _contextType;
  String? _contextid;

  String? get app => _app;
  String? get searchKeyword => _searchKeyword;
  String? get appVer => _appVer;
  String? get action => _action;
  String? get contextType => _contextType;
  String? get contextid => _contextid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['app'] = _app;
    map['search_keyword'] = _searchKeyword;
    map['app_ver'] = _appVer;
    map['action'] = _action;
    map['context_type'] = _contextType;
    map['contextid'] = _contextid;
    return map;
  }

}