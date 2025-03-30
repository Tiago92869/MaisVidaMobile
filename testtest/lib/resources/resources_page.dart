import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:testtest/services/resource/resource_service.dart';
import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/resources/resource_detail_page.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final ResourceService _resourceService = ResourceService();

  // Set to store selected resource types
  Set<ResourceType> _selectedResourceTypes = {};

  // List of all available resource types for the filter
  final List<ResourceType> _resourceTypes = ResourceType.values;

  // List of resources fetched from the service
  List<Resource> _resources = [];

  // Search input text
  String _searchText = "";

  // Loading state
  bool _isLoading = false;

  // Control the visibility of the sliding filter panel
  bool _isFilterPanelVisible = false;

  // Set to track if the star icon is glowing
  bool _isStarGlowing = false;

  @override
  void initState() {
    super.initState();

    // Add mock resources for testing
    _resources = [
      Resource(
        id: "1",
        title: "How to Stay Healthy",
        description: "Learn the best practices for maintaining a healthy lifestyle.",
        type: ResourceType.ARTICLE,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Resource(
        id: "2",
        title: "10-Minute Workout",
        description: "A quick and effective workout routine for busy people.",
        type: ResourceType.EXERCISE,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Resource(
        id: "3",
        title: "Meditation for Beginners",
        description: "A guide to help you start meditating and reduce stress.",
        type: ResourceType.PODCAST,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Resource(
        id: "4",
        title: "Healthy Recipes",
        description: "Delicious and nutritious recipes for a balanced diet.",
        type: ResourceType.RECIPE,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now().subtract(const Duration(days: 35)),
      ),
      Resource(
        id: "5",
        title: "Emergency Contacts",
        description: "Important contacts to call in case of an emergency.",
        type: ResourceType.SOS,
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
        updatedAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }

  // Function to fetch resources
  Future<void> _fetchResources() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final resourcePage = await _resourceService.fetchResources(
        _selectedResourceTypes.toList(),
        0, // Page number
        20, // Page size
        _searchText,
      );
      setState(() {
        _resources = resourcePage.content;
      });
    } catch (e) {
      print('Error fetching resources: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch resources. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to toggle resource type selection
  void _toggleResourceType(ResourceType type) {
    setState(() {
      if (_selectedResourceTypes.contains(type)) {
        _selectedResourceTypes.remove(type);
      } else {
        _selectedResourceTypes.add(type);
      }
    });
    _fetchResources();
  }

  // Function to handle search input
  void _onSearch(String text) {
    setState(() {
      _searchText = text;
    });
    _fetchResources();
  }

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

  // Function to toggle the star glow
  void _toggleStarGlow() {
    setState(() {
      _isStarGlowing = !_isStarGlowing;
    });
  }

  // Function to map ResourceType to image paths
  static String getImageForResourceType(ResourceType type) {
    switch (type) {
      case ResourceType.ARTICLE:
        return 'assets/images/resources/newspaper.png';
      case ResourceType.VIDEO:
        return 'assets/images/resources/video.png';
      case ResourceType.PODCAST:
        return 'assets/images/resources/recording.png';
      case ResourceType.PHRASE:
        return 'assets/images/resources/training-phrase.png';
      case ResourceType.CARE:
        return 'assets/images/resources/healthcare.png';
      case ResourceType.EXERCISE:
        return 'assets/images/resources/physical-wellbeing.png';
      case ResourceType.RECIPE:
        return 'assets/images/resources/recipe.png';
      case ResourceType.MUSIC:
        return 'assets/images/resources/headphones.png';
      case ResourceType.SOS:
        return 'assets/images/resources/sos.png';
      case ResourceType.OTHER:
        return 'assets/images/resources/other.png';
      default:
        return 'assets/samples/ui/rive_app/images/topics/topic_1.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with blur effect when filter is open
          GestureDetector(
            onTap: _closeFilterPanel,
            child: IgnorePointer(
              ignoring: _isFilterPanelVisible, // Disable interactions when the filter is open
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _fetchResources, // Call _fetchResources on pull-down
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(), // Ensure pull-down is always possible
                      child: Container(
                        color: Colors.transparent, // Detect taps anywhere on the screen
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60), // Add spacing between the top of the screen and the title
                            // Title (Resources) centered at the top
                            const Center(
                              child: Text(
                                "Resources",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontFamily: "Poppins",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            // Input TextField with Search icon
                            TextField(
                              onChanged: _onSearch,
                              decoration: InputDecoration(
                                labelText: "Search Resources",
                                labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Colors.grey),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            // Display the resources as HCards
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : Column(
                                    children: _resources
                                        .map(
                                          (resource) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ResourceDetailPage(resource: resource),
                                                    ),
                                                  );
                                                },
                                                child: _buildHCard(resource),
                                              ),
                                            );
                                          },
                                        )
                                        .toList(),
                                  ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Apply blur effect when filter panel is visible
                  if (_isFilterPanelVisible)
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity
                      child: Container(
                        color: Colors.black.withOpacity(0.2), // Optional: Add a semi-transparent overlay
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Filter Icon Positioned
          Positioned(
            top: 58,
            right: 20,
            child: Row(
              children: [
                // Star Icon
                GestureDetector(
                  onTap: _toggleStarGlow,
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
                            color: _isStarGlowing
                                ? Colors.blue.withOpacity(0.8) // Glowing shadow when pressed
                                : Colors.black.withOpacity(0.2), // Default shadow when not pressed
                            blurRadius: _isStarGlowing ? 15 : 5,
                            spreadRadius: _isStarGlowing ? 5 : 0,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star,
                        color: _isStarGlowing ? Colors.blue : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter Icon
                GestureDetector(
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
                      child: const Icon(
                        Icons.filter_alt,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sliding filter panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isFilterPanelVisible ? 0 : -230, // Slide in/out effect
            top: 0,
            bottom: 0,
            child: Container(
              width: 230,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(72, 85, 204, 1), // Start color (darker blue)
                    Color.fromRGBO(123, 144, 255, 1), // End color (lighter blue)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(-5, 0), // Shadow on the left side
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40), // Space between the arrow and text
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 15),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleFilterPanel,
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 30),
                        const Text(
                          "Filter by Type",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _resourceTypes.map((resourceType) {
                            bool isSelected = _selectedResourceTypes.contains(resourceType);
                            return GestureDetector(
                              onTap: () => _toggleResourceType(resourceType),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: isSelected
                                      ? const Color.fromRGBO(85, 123, 233, 1) // Selected button color
                                      : Colors.white, // Default button color
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text(
                                    StringCapitalization(resourceType.toString().split('.').last).capitalizeFirstLetter(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color.fromRGBO(72, 85, 204, 1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHCard(Resource resource) {
    const int maxDescriptionLength = 30; // Maximum length for the description (fits around two lines)

    String truncatedDescription = resource.description.length > maxDescriptionLength
        ? '${resource.description.substring(0, maxDescriptionLength)}...'
        : resource.description;

    return Container(
      constraints: const BoxConstraints(maxHeight: 110),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent, // Replace with a dynamic color if needed
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Poppins",
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  truncatedDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "Inter",
                    color: Colors.white,
                  ),
                  maxLines: 2, // Ensure it doesn't exceed two lines
                  overflow: TextOverflow.ellipsis, // Add ellipsis if it overflows
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: VerticalDivider(thickness: 0.8, width: 0),
          ),
          Opacity(
            opacity: 0.9,
            child: Image.asset(
              getImageForResourceType(resource.type),
              width: 48, // Set the width to 48
              height: 48, // Set the height to 48
              fit: BoxFit.contain, // Ensure the image fits within the bounds
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
