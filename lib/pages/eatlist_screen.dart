import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nutrition_app/controllers/eatlist_controller.dart';
import 'package:nutrition_app/models/product.dart'; // Your product model

class EatlistScreen extends StatelessWidget {
  final EatlistController eatlistController = Get.find();

  // Using RxString for reactive calorie goal
  final RxString calorieGoal = ''.obs;

  // Function to show the calorie goal input dialog
  void _showCalorieGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Daily Calorie Goal'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter your calorie goal',
            ),
            onChanged: (value) {
              calorieGoal(value); // Update the calorie goal reactively
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally, add validation for the input here
              },
              child: const Text('Set Goal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show the dialog when the screen is first loaded
    Future.delayed(Duration.zero, () => _showCalorieGoalDialog(context));

    return Scaffold(
      appBar: AppBar(title: const Text('Eatlist')),
      body: Stack(
        children: [
          // Eatlist items
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              return ListView.builder(
                itemCount: eatlistController.eatlist.length,
                itemBuilder: (context, index) {
                  Product product = eatlistController.eatlist[index];
                  return ListTile(
                    title: Text(product.name ?? 'No Name'),
                    subtitle: Text(
                        'Energy: ${product.nutriments?.energyKcal} kcal'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        eatlistController.removeFromEatlist(product);
                      },
                    ),
                  );
                },
              );
            }),
          ),
          // Calorie goal overlay at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                // Calculate total calories from the eatlist
                double totalCalories = eatlistController.eatlist.fold(
                    0.0,
                    (sum, product) =>
                        sum + (product.nutriments?.energyKcal ?? 0.0));

                // Get the daily goal (it will be empty if not set)
                double dailyGoal = double.tryParse(calorieGoal.value) ?? 0.0;
                double caloriesRemaining = dailyGoal - totalCalories;

                return Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      if (dailyGoal > 0)
                        Text(
                          'Daily Calorie Goal: ${dailyGoal.toStringAsFixed(0)} kcal',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      if (dailyGoal > 0)
                        Text(
                          'Calories consumed: ${totalCalories.toStringAsFixed(2)} kcal',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      if (dailyGoal > 0)
                        Text(
                          'Calories to hit goal: ${caloriesRemaining > 0 ? caloriesRemaining.toStringAsFixed(2) : '0'} kcal',
                          style: TextStyle(
                            color: caloriesRemaining > 0
                                ? Colors.green
                                : Colors.red,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
