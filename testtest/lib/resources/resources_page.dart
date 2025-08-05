import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter_scroll_shadow/flutter_scroll_shadow.dart';
import 'package:maisvida/services/favorite/favorite_service.dart';
import 'package:maisvida/services/resource/resource_service.dart';
import 'package:maisvida/services/resource/resource_model.dart';
import 'package:maisvida/resources/resource_detail_page.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final ResourceService _resourceService = ResourceService();
  final FavoriteService _favoriteService = FavoriteService();

  // Set to store selected resource types
  final Set<ResourceType> _selectedResourceTypes = {};

  // List of all available resource types for the filter
  final List<ResourceType> _resourceTypes = ResourceTypeExtension.getFilterableTypes();

  // List of resources fetched from the service
  List<Resource> _resources = [];

  // Search input text
  String _searchText = "";

  // Loading state
  bool _isLoading = false;

  // Pagination state
  int _currentPage = 0;
  bool _isLastPage = false;

  // Control the visibility of the sliding filter panel
  bool _isFilterPanelVisible = false;

  // Set to track if the star icon is glowing
  bool _isStarGlowing = false;

  // Define resource colors (same as _activityColors)
  final List<Color> _resourceColors = [
    const Color(0xFF9CC5FF),
    const Color(0xFF6E6AE8),
    const Color(0xFF005FE7),
    const Color(0xFFBBA6FF),
  ];

  @override
  void initState() {
    super.initState();
    _fetchResources(); // Fetch the first page of resources when the page opens
  }

  // Function to fetch resources
  Future<void> _fetchResources() async {
    if (_isLoading || _isLastPage) return; // Prevent duplicate or unnecessary requests

    setState(() {
      _isLoading = true;
    });

    try {
      final resourcePage = await _resourceService.fetchResources(
        _selectedResourceTypes.toList(), // Pass the selected resource types
        page: _currentPage, // Use named parameter for page
        size: 10, // Use named parameter for size
        search: _searchText, // Use named parameter for search
      );

      setState(() {
        _resources.addAll(
          resourcePage.content,
        ); // Append new resources to the list
        _isLastPage = resourcePage.last; // Check if this is the last page
        _currentPage++; // Increment the page number for the next fetch
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao procurar recursos. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to fetch favorite resources
  Future<void> _fetchFavoriteResources() async {
    try {
      final favoriteResources = await _favoriteService.fetchFavoriteResources();
      setState(() {
        _resources = favoriteResources; // Update the resources list with favorites
        _isLastPage = true; // Assume all favorite resources are loaded
      });
    } catch (e) {
      // If error (e.g., 404), clear the resources list
      setState(() {
        _resources.clear();
        _isLastPage = true;
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
      _resources.clear(); // Clear the current list of resources
      _currentPage = 0; // Reset to the first page
      _isLastPage = false; // Reset the last page flag
    });
    _fetchResources(); // Fetch resources with the updated filters
  }

  // Function to handle search input
  void _onSearch(String text) {
    setState(() {
      _searchText = text;
      _resources.clear(); // Clear the current list of resources
      _currentPage = 0; // Reset to the first page
      _isLastPage = false; // Reset the last page flag
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

  // Function to detect when the user scrolls to the bottom
  void _onScroll(ScrollController controller) {
    if (controller.position.pixels >=
            controller.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLastPage) {
      _fetchResources(); // Fetch the next page when near the bottom
    }
  }

  // Show information dialog
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
                  "Este é o ecrã dos Recursos, onde pode encontrar todo o material educativo disponível.\n\n"
                  "Neste ecrã, pode:\n"
                  "  - Ver os recursos que já marcou como favoritos para aceder mais rápido.\n"
                  "  - Pesquisar recursos pelo nome, para encontrar facilmente o que procura.\n"
                  "  - Filtrar os recursos pelo tipo, como artigo, podcast ou vídeo, conforme preferir.\n\n"
                  "Ao escolher um recurso, pode:\n"
                  "  - Ver o conteúdo completo para aprender sobre o tema.\n"
                  "  - Marcar o recurso como favorito para guardar e consultar mais tarde.\n"
                  "  - Dar o seu feedback, dizendo o que achou do recurso e ajudando a melhorar.",
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
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() => _onScroll(scrollController));

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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
          // Main content
          GestureDetector(
            onTap: _closeFilterPanel,
            child: IgnorePointer(
              ignoring:
                  _isFilterPanelVisible, // Disable interactions when the filter is open
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  // Header with title and icons - matching goals_page structure
                  Stack(
                    children: [
                      Center(
                        child: const Text(
                          "Recursos",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Info icon on the left side
                      Positioned(
                        top: 0,
                        left: 70,
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
                      // Star icon on the right
                      Positioned(
                        top: 0,
                        right: 60,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              _isStarGlowing = !_isStarGlowing;
                            });

                            if (_isStarGlowing) {
                              await _fetchFavoriteResources();
                            } else {
                              setState(() {
                                _resources.clear();
                                _currentPage = 0;
                                _isLastPage = false;
                              });
                              _fetchResources();
                            }
                          },
                          child: Container(
                            width: 37,
                            height: 37,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.star,
                              color: _isStarGlowing ? const Color.fromARGB(255, 255, 217, 0) : const Color(0xFF0D1B2A),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // Filter icon
                      Positioned(
                        top: 0,
                        right: 10,
                        child: GestureDetector(
                          onTap: _toggleFilterPanel,
                          child: Container(
                            width: 37,
                            height: 37,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.filter_alt,
                              color: Color(0xFF0D1B2A),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        labelText: "Procurar recursos",
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _resources.clear();
                          _currentPage = 0;
                          _isLastPage = false;
                        });
                        await _fetchResources();
                      },
                      child: _resources.isEmpty
                          ? Center(
                                child: Text(
                                  "Nenhum recurso encontrado",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 80),
                              itemCount: _resources.length,
                              itemBuilder: (context, index) {
                                final resource = _resources[index];
                                final backgroundColor =
                                    _resourceColors[index % _resourceColors.length];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: GestureDetector(
                                    onTap: () async {
                                      // Navigate to ResourceDetailPage and wait for the result
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ResourceDetailPage(resource: resource),
                                        ),
                                      );

                                      // Refresh the resources list when returning
                                      if (_isStarGlowing) {
                                        // If the star icon is glowing, fetch favorite resources
                                        await _fetchFavoriteResources();
                                      } else {
                                        // Otherwise, refresh the default resources list
                                        _onSearch(_searchText);
                                      }
                                    },
                                    child: _buildHCard(resource, backgroundColor),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Blur effect under the filter panel
          if (_isFilterPanelVisible)
            GestureDetector(
              onTap: _closeFilterPanel,
              child: _buildBlurEffect(),
            ),
          // Sliding Filter Panel
          _buildFilterPanel(),
          // Loading indicator in the center of the screen
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // Get emoji for resource type
  String _getResourceEmoji(ResourceType type) {
    switch (type) {
      case ResourceType.ARTICLE:
        return "📖";
      case ResourceType.VIDEO:
        return "🎬";
      case ResourceType.PODCAST:
        return "🎧";
      case ResourceType.PHRASE:
        return "💬";
      case ResourceType.CARE:
        return "💚";
      case ResourceType.EXERCISE:
        return "🏋️";
      case ResourceType.RECIPE:
        return "🍲";
      case ResourceType.MUSIC:
        return "🎵";
      case ResourceType.SOS:
        return "🚨";
      case ResourceType.OTHER:
        return "🗂️";
      case ResourceType.TIVA:
        return "🧠";
      }
  }

  // Get display name for resource type (without emoji)
  String _getResourceDisplayName(ResourceType type) {
    switch (type) {
      case ResourceType.ARTICLE:
        return "Artigo";
      case ResourceType.VIDEO:
        return "Vídeo";
      case ResourceType.PODCAST:
        return "Podcast";
      case ResourceType.PHRASE:
        return "Frase";
      case ResourceType.CARE:
        return "Cuidado";
      case ResourceType.EXERCISE:
        return "Exercício";
      case ResourceType.RECIPE:
        return "Receita";
      case ResourceType.MUSIC:
        return "Música";
      case ResourceType.SOS:
        return "Ajuda";
      case ResourceType.OTHER:
        return "Outro";
      case ResourceType.TIVA:
        return "Tiva";
      }
  }

  Widget _buildFilterPanel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: _isFilterPanelVisible ? 0 : -230, // Slide in/out effect
      top: 0,
      bottom: 0,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0D1B2A), // Start color (igual ao fundo)
              Color(0xFF1B263B), // End color (igual ao fundo)
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
                    "Tipo", // Tradução para português
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                    children:
                        _resourceTypes.map((resourceType) {
                          bool isSelected = _selectedResourceTypes.contains(
                            resourceType,
                          );
                          String emoji = _getResourceEmoji(resourceType);
                          String resourceDisplay = _getResourceDisplayName(resourceType);
                          
                          return GestureDetector(
                            onTap: () => _toggleResourceType(resourceType),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.transparent,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color:
                                    isSelected
                                        ? const Color(0xFF0D1B2A)
                                        : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 15,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      resourceDisplay,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF0D1B2A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHCard(Resource resource, Color backgroundColor) {
    const int maxDescriptionLength = 90; // expandido para permitir até ~2 linhas

    String truncatedDescription = resource.description.length > maxDescriptionLength
        ? '${resource.description.substring(0, maxDescriptionLength)}...'
        : resource.description;

    return Container(
      width: double.infinity, // Full width to reach the end of the page
      constraints: const BoxConstraints(minHeight: 140), // altura mínima, cresce conforme necessário
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Reduced horizontal padding
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.65), // reduz opacidade do fundo
        borderRadius: BorderRadius.circular(25), // Slightly reduced border radius
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  truncatedDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getResourceEmoji(resource.type),
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getResourceDisplayName(resource.type),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15), // Reduced spacing
        ],
      ),
    );
  }

}

Widget _buildBlurEffect() {
  return BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    child: Container(color: Colors.black.withOpacity(0.2)),
  );
}

// Extension to capitalize the first letter of a string
extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (this.isEmpty) return this;
    if (this == "SOS") return "SOS";
    return this[0].toUpperCase() + this.substring(1).toLowerCase();
  }
}