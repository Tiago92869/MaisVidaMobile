import 'package:flutter/material.dart';
import 'package:testtest/resources/resource_detail_page.dart';
import 'package:testtest/services/resource/resource_service.dart';
import 'package:testtest/services/resource/resource_model.dart';

class SosDetailsPage extends StatefulWidget {
  const SosDetailsPage({Key? key}) : super(key: key);

  @override
  _SosDetailsPageState createState() => _SosDetailsPageState();
}

class _SosDetailsPageState extends State<SosDetailsPage> {
  final ResourceService _resourceService = ResourceService();
  List<Resource> _sosResources = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Add mock SOS resources for testing
    _sosResources = [
      Resource(
        id: "1",
        title: "Local Hospital",
        description: "24/7 emergency services available at the local hospital.",
        type: ResourceType.SOS,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Resource(
        id: "2",
        title: "Fire Department",
        description: "Emergency fire services for immediate assistance.",
        type: ResourceType.SOS,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Resource(
        id: "3",
        title: "Police Station",
        description: "Contact the police station for urgent law enforcement needs.",
        type: ResourceType.SOS,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Resource(
        id: "4",
        title: "Poison Control Center",
        description: "Get immediate help for poisoning emergencies.",
        type: ResourceType.SOS,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Resource(
        id: "5",
        title: "Mental Health Hotline",
        description: "24/7 support for mental health crises.",
        type: ResourceType.SOS,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];

    _isLoading = false; // Set loading to false since we're using mock data

    _fetchSosResources();
  }

  Future<void> _fetchSosResources() async {
  try {
    final resources = await _resourceService.fetchResources(
      [ResourceType.SOS], // Filter by SOS type
      0, // Page number
      20, // Page size
      "", // No search query
    );
    setState(() {
      _sosResources = resources.content;
      _isLoading = false;
    });
  } catch (e) {
    print('Error fetching SOS resources: $e');
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Failed to fetch SOS resources. Please try again."),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _navigateToResourceDetail(BuildContext context, Resource resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceDetailPage(resource: resource),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D1B2A), // Dark blue start color
                    Color(0xFF1B263B), // Dark blue end color
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    "SOS Details",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Highlighted urgent color
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Two clickable squares
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Handle Medical Emergency click
                          print("Medical Emergency clicked");
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Medical Emergency",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle Emergency Contact click
                          print("Emergency Contact clicked");
                        },
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Emergency Contact",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Resources section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Emergency Resources",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Center(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 30),
                                itemCount: _sosResources.length,
                                itemBuilder: (context, index) {
                                  final resource = _sosResources[index];
                                  return GestureDetector(
                                    onTap: () => _navigateToResourceDetail(context, resource),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      padding: const EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2C3E50), // Darker blue for resource cards
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.redAccent,
                                            radius: 25,
                                            child: const Icon(
                                              Icons.info,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(
                                              resource.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
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
        ],
      ),
    );
  }
}