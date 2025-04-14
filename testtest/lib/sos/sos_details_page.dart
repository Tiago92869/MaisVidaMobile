import 'package:flutter/material.dart';
import 'package:testtest/resources/resource_detail_page.dart';
import 'package:testtest/services/resource/resource_service.dart';
import 'package:testtest/services/resource/resource_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class SosDetailsPage extends StatefulWidget {
  const SosDetailsPage({Key? key}) : super(key: key);

  @override
  _SosDetailsPageState createState() => _SosDetailsPageState();
}

class _SosDetailsPageState extends State<SosDetailsPage> {
  final ResourceService _resourceService = ResourceService();
  List<Resource> _sosResources = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 0;
  bool _isLastPage = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSosResources();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchSosResources(loadNextPage: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchSosResources({bool loadNextPage = false}) async {
    if (_isLoading || (loadNextPage && _isLastPage)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final resources = await _resourceService.fetchResources(
        [ResourceType.SOS],
        page: loadNextPage ? _currentPage : 0,
        size: 10,
        search: "",
      );

      setState(() {
        if (loadNextPage) {
          _sosResources.addAll(resources.content ?? []);
        } else {
          _sosResources = resources.content ?? [];
        }
        _isLastPage = resources.last ?? true;
        _currentPage = (resources.number ?? 0) + 1;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to fetch SOS resources.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    print("Trying to dial: $phoneUri");
    print("Can launch: ${await canLaunchUrl(phoneUri)}");
    final status = await Permission.phone.status;
    if (status.isDenied || status.isRestricted) {
      final result = await Permission.phone.request();
      if (!result.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Phone call permission is required."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to launch phone dialer."),
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
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
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
                  const Text(
                    "SOS Details",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _makePhoneCall("+351910774893"),
                        child: _buildEmergencyBox(
                          "Medical Emergency",
                          Colors.redAccent,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _makePhoneCall("+351910774893"),
                        child: _buildEmergencyBox(
                          "Emergency Contact",
                          Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
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
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _currentPage = 0;
                        _isLastPage = false;
                        await _fetchSosResources();
                      },
                      child:
                          _isLoading && _sosResources.isEmpty
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
                                controller: _scrollController,
                                padding: const EdgeInsets.only(bottom: 30),
                                itemCount:
                                    _sosResources.length + (_isLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index < _sosResources.length) {
                                    final resource = _sosResources[index];
                                    return GestureDetector(
                                      onTap:
                                          () => _navigateToResourceDetail(
                                            context,
                                            resource,
                                          ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2C3E50),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
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
                                                resource.title ?? "Untitled",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                                  } else {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                },
                              ),
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

  Widget _buildEmergencyBox(String title, Color color) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
