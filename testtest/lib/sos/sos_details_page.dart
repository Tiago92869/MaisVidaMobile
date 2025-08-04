import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
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
          _sosResources.addAll(resources.content);
        } else {
          _sosResources = resources.content;
        }
        _isLastPage = resources.last;
        _currentPage = (resources.number) + 1;
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
    if (number == null || number.isEmpty) {
      _showNoContactDialog();
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: number);

    if (Platform.isAndroid) {
      final status = await Permission.phone.status;

      if (status.isDenied || status.isRestricted) {
        final result = await Permission.phone.request();

        if (!result.isGranted) {
          _showPermissionError();
          return;
        }
      }
    }

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
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

  Future<void> _showInfoDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1B2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Informação",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            height: 340,
            width: 400,
            child: ScrollShadow(
              color: Colors.white.withOpacity(0.3),
              size: 15.0,
              fadeInCurve: Curves.easeIn,
              fadeOutCurve: Curves.easeOut,
              child: SingleChildScrollView(
                child: const Text(
                  "Esta é a página SOS, onde pode encontrar ajuda rápida em situações de emergência.\n\n"
                  "Aqui, pode aceder a dois canais importantes:\n"
                  "  - O contacto do SNS24, para falar com profissionais de saúde em caso de urgência.\n"
                  "  - O contacto de emergência que guardou, para chamar alguém próximo quando precisar.\n\n"
                  "Além disso, pode consultar os Recursos SOS, que são informações e dicas úteis para lidar com várias situações de emergência.\n\n"
                  "Esta página foi pensada para estar sempre ao seu alcance, para que possa agir rapidamente quando mais precisar, com segurança e tranquilidade.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
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
              ),
              const SizedBox(height: 25),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: const Align(
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
                            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 80),
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
                                        const Text(
                                          '🚨',
                                          style: TextStyle(
                                            fontSize: 32,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            resource.title,
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
          // Info icon moved to the right side
          Positioned(
            top: 58,
            right: 30,
            child: GestureDetector(
              onTap: _showInfoDialog,
              child: Container(
                width: 37,
                height: 37,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.info_outline,
                    color: Color(0xFF0D1B2A),
                    size: 24,
                  ),
                ),
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
