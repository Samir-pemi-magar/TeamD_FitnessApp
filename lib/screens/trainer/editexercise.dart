import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/screens/trainer/trainer_dashboard.dart';
import 'package:fitnessapp/screens/user/Packages/packages.dart';
import 'package:fitnessapp/screens/user/WaterIntake/WaterIntake.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TrainerExerciseEditor extends StatefulWidget {
  const TrainerExerciseEditor({super.key});

  @override
  State<TrainerExerciseEditor> createState() => _TrainerExerciseEditorState();
}

class _TrainerExerciseEditorState extends State<TrainerExerciseEditor> {
  int age = 0;
  String packageName = '';
  String ageRangeLabel = '';
  List<QueryDocumentSnapshot> fetchedDocs = [];
  int _selectedIndex = 0;

  final TextEditingController ageController = TextEditingController();
  final TextEditingController packageController = TextEditingController();

  String getCollectionName(int age) {
    if (age >= 15 && age <= 24) {
      ageRangeLabel = "Young Adults (15-24)";
      return '(15-24)';
    } else if (age >= 25 && age <= 39) {
      ageRangeLabel = "Adults (25-39)";
      return '(25-39)';
    } else {
      ageRangeLabel = "Seniors (40+)";
      return '(40+)';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TrainerDashboard()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WaterIntake()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Packages()),
        );
        break;
      case 3:
        print("Profile screen not made yet");
        break;
    }
  }

  Future<void> fetchExercises() async {
    try {
      String collection = getCollectionName(age);

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .where('package', isEqualTo: packageName)
              .get();

      if (!mounted) return;
      setState(() {
        fetchedDocs = snapshot.docs;
      });
    } catch (e) {
      print("Error fetching exercises: $e");
    }
  }

  Future<void> updateExercise(
    String docId,
    String collection,
    Map<String, dynamic> updatedData,
  ) async {
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .update(updatedData);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Exercise updated!")));
  }

  void showEditDialog(QueryDocumentSnapshot doc, String collection) {
    final titleController = TextEditingController(text: doc['title']);
    final detailController = TextEditingController(text: doc['detail']);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Edit Exercise'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: detailController,
                    decoration: const InputDecoration(labelText: 'Detail'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  updateExercise(doc.id, collection, {
                    'title': titleController.text,
                    'detail': detailController.text,
                  });
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    packageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Exercise Editor'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TrainerDashboard()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(143, 255, 248, 225),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: ageController,
                      decoration: const InputDecoration(labelText: 'Enter Age'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: packageController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Package Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          age = int.tryParse(ageController.text) ?? 0;
                          packageName = packageController.text;
                        });
                        fetchExercises();
                      },
                      child: const Text('Fetch Exercises'),
                    ),
                    const SizedBox(height: 16),
                    Text('Age Group: $ageRangeLabel'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: fetchedDocs.length,
                  itemBuilder: (context, index) {
                    final doc = fetchedDocs[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'title: ${doc['title'] ?? 'No Title'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            Text(
                              'description:\n${doc['detail'] ?? 'No Detail'}',
                              style: const TextStyle(height: 1.5),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  final collection = getCollectionName(age);
                                  showEditDialog(doc, collection);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.droplet),
            label: 'Water Intake',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.box),
            label: 'Packages',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 84, 86, 82),
      ),
    );
  }
}
