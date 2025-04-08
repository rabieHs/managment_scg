import 'package:flutter/material.dart';
import 'package:managment_system/models/chef.dart';
import 'package:managment_system/services/chef_services.dart';

import 'add_chef_screen.dart';

class ChefsScreen extends StatefulWidget {
  const ChefsScreen({Key? key}) : super(key: key);

  @override
  State<ChefsScreen> createState() => _ChefsScreenState();
}

class _ChefsScreenState extends State<ChefsScreen> {
  late Future<List<Chef>> _chefsFuture;
  final ChefServices _chefService = ChefServices();

  @override
  void initState() {
    super.initState();
    _chefsFuture = _chefService.getChefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chefs Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'List of Chefs will be here',
              style: TextStyle(fontSize: 20),
            ),
            Expanded(
              child: FutureBuilder<List<Chef>>(
                future: _chefsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final chef = snapshot.data![index];
                        return ListTile(
                          title: Text(chef.name),
                          subtitle: Text(chef.speciality.join(
                              ', ')), // Display specialities as comma-separated string
                          // Add more details or actions here
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('No chefs found'));
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddChefScreen()),
                );
              },
              child: const Text('Add New Chef'),
            ),
          ],
        ),
      ),
    );
  }
}
