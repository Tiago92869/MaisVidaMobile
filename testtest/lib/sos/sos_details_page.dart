import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mentara/resources/resource_detail_page.dart';
import 'package:mentara/services/resource/resource_service.dart';
import 'package:mentara/services/resource/resource_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

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
        _errorMessage = "Falha ao procurar recursos do SOS.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall(String? number) async {
  print("📱 Platform check — is iOS: ${Platform.isIOS}");
  print("📱 Platform check — is Android: ${Platform.isAndroid}");

  if (number == null || number.isEmpty) {
    print("⚠️ No number provided, showing no contact dialog.");
    _showNoContactDialog();
    return;
  }

  final Uri phoneUri = Uri(scheme: 'tel', path: number);
  print("📞 Constructed phone URI: $phoneUri");

  if (Platform.isAndroid) {
    print("🤖 On Android — checking phone permissions...");

    final status = await Permission.phone.status;
    print("📊 Permission status: $status");

    if (status.isDenied || status.isRestricted) {
      print("🔒 Permission is denied or restricted — requesting permission...");
      final result = await Permission.phone.request();
      print("📊 Permission request result: $result");

      if (!result.isGranted) {
        print("❌ Permission not granted — showing permission error.");
        _showPermissionError();
        return;
      } else {
        print("✅ Permission granted.");
      }
    } else {
      print("✅ Permission already granted.");
    }
  } else {
    print("🍏 On iOS — skipping permission check.");
  }

  print("🚀 Checking if can launch URI...");

  if (await canLaunchUrl(phoneUri)) {
    print("✅ Can launch URI — launching...");
    await launchUrl(phoneUri);
  } else {
    print("❌ Cannot launch URI — showing launch error.");
    _showLaunchError();
  }
}


  void _showNoContactDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Erro",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Contacto de emergência não definido.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showPermissionError() {
  print("🚨 _showPermissionError triggered");
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("É necessária permissão para chamada telefónica."),
      backgroundColor: Colors.red,
    ),
  );
}

void _showLaunchError() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Não é possível redirecionar para as chamadas"),
      backgroundColor: Colors.red,
    ),
  );
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
                    "Detalhes SOS",
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
                        onTap: () => _makePhoneCall("+351808242424"),
                        child: _buildEmergencyBox(
                          "Emergência médica",
                          Colors.redAccent,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final emergencyContact =
                              await _fetchEmergencyContact();
                          _makePhoneCall(emergencyContact);
                        },
                        child: _buildEmergencyBox(
                          "Contacto de emergência",
                          Colors.orangeAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recursos de emergência",
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
                                                resource.title ?? "Sem título",
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

  Future<String?> _fetchEmergencyContact() async {
    final FlutterSecureStorage storage = const FlutterSecureStorage();
    return await storage.read(key: 'emergencyContact');
  }
}
