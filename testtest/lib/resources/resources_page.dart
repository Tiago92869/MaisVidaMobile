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
  ASD,
  ASDASD,
  ASDASDASD,
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

  // Control the visibility of the sliding filter panel
  bool _isFilterPanelVisible = false;

  // Function to toggle the filter panel visibility
  void _toggleFilterPanel() {
    setState(() {
      _isFilterPanelVisible = !_isFilterPanelVisible;
    });
  }

  // Function to close filter panel when tapping outside
  void _closeFilterPanel() {
    if (_isFilterPanelVisible) {
      setState(() {
        _isFilterPanelVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Detect tap outside filter panel to close it
          GestureDetector(
            onTap: _closeFilterPanel,
            child: IgnorePointer(
              ignoring: _isFilterPanelVisible, // Disable interactions when the filter is open
              child: Container(
                color: Colors.transparent, // Detect taps anywhere on the screen
                child: Padding(
                  padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 40), // Adjusted spacing
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title (Resources) centered at the top
                        Center(
                          child: Text(
                            "Resources",
                            style: TextStyle(
                              fontSize: 24, // Reduced font size
                              fontFamily: "Poppins",
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Input TextField with Search icon
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Search Resources",
                            labelStyle: TextStyle(color: Colors.grey, fontSize: 14), // Smaller font
                            prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20), // Smaller icon
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20), // Smaller border radius
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Reduced padding
                          ),
                          style: TextStyle(fontSize: 14), // Reduced text input font size
                        ),
                        SizedBox(height: 20),
                        // Display the courseSections as HCards
                        Column(
                          children: _courseSections
                              .map(
                                (section) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: HCard(section: section),
                                ),
                              )
                              .toList(),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Filter Icon Positioned
          Positioned(
            top: 58,
            right: 20,
            child: GestureDetector(
              onTap: _toggleFilterPanel,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  width: 40,
                  height: 40,
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
                    Icons.filter_alt,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          // Sliding filter panel
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            right: _isFilterPanelVisible ? 0 : -230, // Slide in/out effect
            top: 0,
            bottom: 0,
            child: Container(
              width: 230,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 40), // Space between the arrow and text
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 15),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleFilterPanel,
                          child: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 30),
                        Text(
                          "Filter by Type",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30), // Added padding to avoid edge cut-off
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
                                duration: Duration(milliseconds: 200),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Colors.blue : Colors.grey[400]!,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected ? Colors.blue : Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15), // Padding inside the button
                                margin: EdgeInsets.symmetric(vertical: 8), // Space between buttons
                                child: Center( // Center the text inside the button
                                  child: Text(
                                    resourceType.toString().split('.').last.capitalizeFirstLetter(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
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
    if (this == "SOS") return "SOS";
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}
