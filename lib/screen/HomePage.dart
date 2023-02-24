import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/databaseHelper.dart';
import '../model/User.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper.databaseHelper;
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  bool isEditing = false;
  late User _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("User data"),
      ),
      body: Column(
        children: [
          Expanded(
              child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'Enter your name', labelText: 'Name'),
                    ),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      decoration: const InputDecoration(hintText: 'Enter your age', labelText: 'Age'),
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(hintText: 'Enter your email', labelText: 'Email'),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              print("Inserted");
                              addOrEditUser();
                            },
                            child: const Text('Submit'),
                          )),
                    ])
                  ]))),
              Expanded(
                flex: 1,
                child: FutureBuilder<List<User>>(
                  future: dbHelper.retrieveUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print(snapshot.data!.length);
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(snapshot.data![index].name),
                              subtitle: Text(snapshot.data![index].email),
                            );
                          });
                    } else if (snapshot.hasError) {
                      print("Error :: ${snapshot.error}");
                      throw Error();
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )
            ],
          )),
        ],
      ),
    );
  }

  Future<void> addOrEditUser() async {
    print("inserted");
    String email = emailController.text;
    String name = nameController.text;
    String age = ageController.text;
    User user = User(name: name, age: age, email: email);
    await addUser(user);

    // if (!isEditing) {
    //   User user = User(name: name, age: int.parse(age), email: email);
    //   await addUser(user);
    // } else {
    //   _user.email = email;
    //   _user.age = int.parse(age);
    //   _user.name = name;
    //   await updateUser(_user);
    // }
    // resetData();
    // setState(() {});
  }

  Future<bool> addUser(User user) async {
    return await dbHelper.insertUser(user);
  }

  Future<int> updateUser(User user) async {
    return await dbHelper.updateUser(user);
  }

  void resetData() {
    nameController.clear();
    ageController.clear();
    emailController.clear();
    isEditing = false;
  }

  Widget userWidget() {
    return FutureBuilder<List<User>>(
      future: dbHelper.retrieveUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data!.length);
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].name),
                  subtitle: Text(snapshot.data![index].email),
                );
              });
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void populateFields(User user) {
    _user = user;
    nameController.text = _user.name;
    ageController.text = _user.age.toString();
    emailController.text = _user.email;
    isEditing = true;
  }
}
/*Dismissible(
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Icon(Icons.delete_forever),
                    ),
                    key: UniqueKey(),
                    onDismissed: (DismissDirection direction) async {
                      await dbHelper.deleteUser(snapshot.data![position].id!);
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => populateFields(snapshot.data![position]),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
                                    child: Text(
                                      snapshot.data![position].name,
                                      style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
                                    child: Text(
                                      snapshot.data![position].email.toString(),
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(100)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          snapshot.data![position].age.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 2.0,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ))*/
