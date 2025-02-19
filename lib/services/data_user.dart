class Datauser {
  List<List<String>> dataUser = [
    ["RizkyKusuma@gmail.com", "123456"],
    ["ArgayStress@gmail.com", "FocusCrypto"]
  ];

  void addUser(String email, String password) {
    dataUser.add([email, password]);
  }
}