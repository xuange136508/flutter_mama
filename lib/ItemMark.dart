/// item_mark_9 : "1663756024"
/// item_name : "cn.mama.pregnant.module.discovery.NewDiscoveryFragment"
/// item_mark_1 : "1663756035"
/// item_mark_2 : "1663756048"

class ItemMark {
  ItemMark({
      required String itemMark9,
    required String itemName,
    required String itemMark1,
    required String itemMark2,}){
    _itemMark9 = itemMark9;
    _itemName = itemName;
    _itemMark1 = itemMark1;
    _itemMark2 = itemMark2;
}

  ItemMark.fromJson(dynamic json) {
    _itemMark9 = json['item_mark_9'];
    _itemName = json['item_name'];
    _itemMark1 = json['item_mark_1'];
    _itemMark2 = json['item_mark_2'];
  }
  String? _itemMark9;
  String? _itemName;
  String? _itemMark1;
  String? _itemMark2;

  String? get itemMark9 => _itemMark9;
  String? get itemName => _itemName;
  String? get itemMark1 => _itemMark1;
  String? get itemMark2 => _itemMark2;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['item_mark_9'] = _itemMark9;
    map['item_name'] = _itemName;
    map['item_mark_1'] = _itemMark1;
    map['item_mark_2'] = _itemMark2;
    return map;
  }

}