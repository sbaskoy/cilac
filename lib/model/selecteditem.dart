class SelectedItem {
  int id;
  bool selected;
  String adi;
  SelectedItem({this.id, this.selected, this.adi});
    Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['selected'] = this.selected;
    data['adi'] = this.adi;
    return data;
  }
}