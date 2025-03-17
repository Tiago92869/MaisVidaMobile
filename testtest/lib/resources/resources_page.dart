import 'package:flutter/material.dart';
import 'package:testtest/menu/models/courses.dart'; // Import the CourseModel
import 'package:testtest/menu/components/hcard.dart'; // Import the HCard widget

enum ResourceType {
  ARTICLE,
  VIDEO,
  PODCAST,
  PHRASE,
  CARE,
  EXERCISE,
  RECIPE,
  MUSIC,
  SOS,
  OTHER,
}

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  // Set to store selected resource types
  Set<ResourceType> _selectedResourceTypes = {};

  // List of all available resource types for the filter
  final List<ResourceType> _resourceTypes = ResourceType.values;

  // Dummy course data
  final List<CourseModel> _courseSections = CourseModel.courseSections;

  // Function to show the filter popup
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filter by Type"), // Updated title
          content: SingleChildScrollView(
            child: Column(
              children: _resourceTypes.map((resourceType) {
                bool isSelected = _selectedResourceTypes.contains(resourceType);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedResourceTypes.remove(resourceType);
                      } else {
                        _selectedResourceTypes.add(resourceType);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200), // Smooth transition for color change
                    width: MediaQuery.of(context).size.width - 40, // Set the width to be the screen width minus padding
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.black, // Blue if selected, black if not
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? Colors.blue : Colors.white, // Blue if selected, white if not
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      // Capitalize only the first letter of the resource type
                      resourceType.toString().split('.').last.capitalizeFirstLetter(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black, // White text if selected, black if not
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Close"), // Changed from Apply to Close
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            color: Colors.white,
          ),
          // Content inside the stack
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40), // Add top spacing here
            child: SingleChildScrollView( // Make the entire body scrollable
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (Resources) centered at the top
                  Center(
                    child: Text(
                      "Resources",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: "Poppins",
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Input TextField with Search icon
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Search Resources",
                      labelStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey), // Search icon inside TextField
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Display the courseSections as HCards (This can be filtered if needed)
                  Column(
                    children: _courseSections
                        .map(
                          (section) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: HCard(section: section), // Use HCard for vertical cards
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Filter Icon Positioned
          Positioned(
            top: 58,
            right: 20, // Positioning filter icon to the right side
            child: GestureDetector(
              onTap: _showFilterDialog, // Show filter dialog when clicked
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 40, // Circle size
                  height: 40, // Circle size
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.filter_alt, // Filter icon
                    color: Colors.blue,
                    size: 28, // Icon size
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (this.isEmpty) return this;
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
