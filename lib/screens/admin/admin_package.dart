import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_add_package.dart';

class AdminPackagesScreen extends StatelessWidget {
  const AdminPackagesScreen({Key? key}) : super(key: key);

  void _editPackage(BuildContext context, String packageId, String currentTitle,
      String currentDescription, String currentPrice) {
    final titleController = TextEditingController(text: currentTitle);
    final descriptionController = TextEditingController(text: currentDescription);
    final priceController = TextEditingController(text: currentPrice);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Package"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? "Title is required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Description is required"
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Price is required";
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return "Enter a valid positive number";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updatedTitle = titleController.text.trim();
                final updatedDescription = descriptionController.text.trim();
                final updatedPrice = priceController.text.trim();

                await FirebaseFirestore.instance
                    .collection('packages')
                    .doc(packageId)
                    .update({
                  'title': updatedTitle,
                  'description': updatedDescription,
                  'price': updatedPrice,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Package updated successfully!",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _deletePackage(BuildContext context, String packageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Package"),
        content: const Text("Are you sure you want to delete this package?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('packages').doc(packageId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Package deleted successfully!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Instant back without confirmation
          },
        ),
        title: const Text("Available Packages", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('packages')
                .orderBy(FieldPath.documentId, descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error loading packages: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No packages found."));
              }

              final packages = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: packages.length + 1,
                itemBuilder: (context, index) {
                  if (index == packages.length) {
                    // Add New Package Card
                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        leading: const Icon(Icons.add, color: Colors.green, size: 30),
                        title: const Text("Add New Package",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddPackageScreen()),
                          );
                        },
                      ),
                    );
                  }

                  final package = packages[index];
                  final title = package['title'] as String? ?? 'No Title';
                  final description = package['description'] as String? ?? 'No Description';
                  final price = package['price'] as String? ?? '0';

                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description),
                          const SizedBox(height: 5),
                          Text("Price: ₹$price"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editPackage(context, package.id, title, description, price);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deletePackage(context, package.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
