import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerRecipieEdit extends StatefulWidget {
  @override
  _TrainerRecipieEditState createState() => _TrainerRecipieEditState();
}

class _TrainerRecipieEditState extends State<TrainerRecipieEdit> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('trainer_recipes').get();

      setState(() {
        recipes =
            snapshot.docs
                .map(
                  (doc) => {
                    'id': doc.id,
                    'title': doc['title'],
                    'instructions': doc['instructions'],
                    'nutrition': doc['nutrition'],
                  },
                )
                .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipes: $e");
    }
  }

  Future<void> updateRecipe(String id, String field, String value) async {
    try {
      await FirebaseFirestore.instance
          .collection('trainer_recipes')
          .doc(id)
          .update({field: value});
    } catch (e) {
      print("Error updating recipe: $e");
    }
  }

  Future<void> addRecipe(
    String title,
    String instructions,
    String nutrition,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('trainer_recipes').add({
        'title': title,
        'instructions': instructions,
        'nutrition': nutrition,
      });
      fetchRecipes();
    } catch (e) {
      print("Error adding recipe: $e");
    }
  }

  void _showAddRecipeDialog() {
    final titleController = TextEditingController();
    final instructionsController = TextEditingController();
    final nutritionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Add New Recipe"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: instructionsController,
                    decoration: InputDecoration(labelText: "Instructions"),
                    maxLines: null,
                  ),
                  TextField(
                    controller: nutritionController,
                    decoration: InputDecoration(labelText: "Nutrition Info"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Add"),
                onPressed: () async {
                  Navigator.pop(context);
                  await addRecipe(
                    titleController.text,
                    instructionsController.text,
                    nutritionController.text,
                  );
                },
              ),
            ],
          ),
    );
  }

  Widget _buildEditableField(
    String id,
    String label,
    String value,
    String field,
  ) {
    TextEditingController controller = TextEditingController(text: value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          onSubmitted: (newValue) {
            updateRecipe(id, field, newValue);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(8),
            border: OutlineInputBorder(),
          ),
          maxLines: field == 'instructions' ? null : 1,
        ),
        SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Trainer Recipes"),
        backgroundColor: const Color(0xFFF7E9AE),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      color: Colors.white.withOpacity(0.85),
                      margin: EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildEditableField(
                              recipe['id'],
                              'Title',
                              recipe['title'],
                              'title',
                            ),
                            _buildEditableField(
                              recipe['id'],
                              'Instructions',
                              recipe['instructions'],
                              'instructions',
                            ),
                            _buildEditableField(
                              recipe['id'],
                              'Nutrition Info',
                              recipe['nutrition'],
                              'nutrition',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecipeDialog,
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFFF7E9AE),
        tooltip: 'Add Recipe',
      ),
    );
  }
}
