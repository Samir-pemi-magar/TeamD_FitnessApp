import 'package:flutter/material.dart';

class RecipesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Recipes"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Text(
                "ZenFit",
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ZenFit Meal Plan Recipes & Nutrition\n(All Goals Combined)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Breakfast Options",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildRecipe(
                        "Oatmeal with banana & almonds",
                        "Cook ½ cup oats in 1 cup water or milk for 5–7 minutes. Top with 1 sliced banana and 5–6 chopped almonds.",
                        "~280 kcal | 6g P | 40g C | 10g F",
                      ),
                      SizedBox(height: 16),
                      _buildRecipe(
                        "Boiled eggs with avocado toast",
                        "Boil 3 eggs. Toast 1 slice whole grain bread, top with ½ mashed avocado. Season lightly.",
                        "~350 kcal | 20g P | 15g C | 25g F",
                      ),
                      SizedBox(height: 16),
                      _buildRecipe(
                        "Chia oats with banana & almonds",
                        "Soak 1 tbsp chia seeds and ¼ cup oats in ½ cup milk overnight. Top with banana slices and chopped almonds.",
                        "~300 kcal | 8g P | 35g C | 12g F",
                      ),
                      SizedBox(height: 16),
                      _buildRecipe(
                        "Chia pudding with berries & boiled egg",
                        "Mix 1 tbsp chia seeds with ½ cup almond milk. Chill overnight. Add berries and serve with 1 boiled egg.",
                        "~320 kcal | 15g P | 30g C | 15g F",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipe(String title, String instructions, String nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(instructions, style: TextStyle(fontSize: 14)),
        SizedBox(height: 4),
        Text(nutrition, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
      ],
    );
  }
}
