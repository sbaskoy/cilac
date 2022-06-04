extension ListExtansion on List {
  getCntText() {
    return this
        .where((e) => e.selected == true)
        .map((e) => e.adi)
        .toString()
        .replaceAll("(", "")
        .replaceAll(")", "");
  }

  getMap() => this.map((e) => e.toJson()).toList();
}

extension StringExr on String {
  String del() => this
      .replaceAll("(", "")
      .replaceAll(")", "")
      .replaceAll(",", ";")
      .replaceAll(" ", "");
}
