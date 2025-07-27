import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:testtest/services/favorite/favorite_service.dart';
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
  final FavoriteService _favoriteService = FavoriteService();

  // Set to store selected resource types
  Set<ResourceType> _selectedResourceTypes = {};

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

  // Track the state of the favorite icon
  bool _isFavoriteFilterEnabled = false;

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
      print('Error fetching resources: $e');
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
      print('Error fetching favorite resources: $e');
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

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() => _onScroll(_scrollController));

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
                  const SizedBox(height: 60),
                  const Center(
                    child: Text(
                      "Recursos",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  const SizedBox(height: 20),
                  Flexible(
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
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
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
          // Filter Icon
          _buildFilterIcon(),
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

  Widget _buildFilterIcon() {
    return Positioned(
      top: 58,
      right: 20,
      child: Row(
        children: [
          // Star Icon
          GestureDetector(
            onTap: () async {
              setState(() {
                _isStarGlowing = !_isStarGlowing; // Toggle the star's glowing state
              });

              if (_isStarGlowing) {
                // Fetch favorite resources when the star is glowing
                await _fetchFavoriteResources();
              } else {
                // Reset the resources list using the existing fetch logic
                setState(() {
                  _resources.clear();
                  _currentPage = 0;
                  _isLastPage = false;
                });
                _fetchResources();
              }
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.star,
                  color: _isStarGlowing ? const Color.fromARGB(255, 255, 217, 0) : Colors.grey,
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
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.filter_alt,
                  color: Color(0xFF0D1B2A), // Igual ao goals_page
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Substitua o método _iconForResourceType pelo getResourceDisplayName para mostrar emoji+nome
  String getResourceDisplayName(ResourceType type) {
    switch (type) {
      case ResourceType.ARTICLE:
        return "📖 Artigo";
      case ResourceType.VIDEO:
        return "🎬 Vídeo";
      case ResourceType.PODCAST:
        return "🎧 Podcast";
      case ResourceType.PHRASE:
        return "💬 Frase";
      case ResourceType.CARE:
        return "💚 Cuidado";
      case ResourceType.EXERCISE:
        return "🏋️ Exercício";
      case ResourceType.RECIPE:
        return "🍲 Receita";
      case ResourceType.MUSIC:
        return "🎵 Música";
      case ResourceType.SOS:
        return "🚨 Ajuda";
      case ResourceType.OTHER:
        return "🗂️ Outro";
      case ResourceType.TIVA:
        return "🧠 Tiva";
      default:
        return "❓ Desconhecido";
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
                                child: Text(
                                  getResourceDisplayName(resourceType),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF0D1B2A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
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
    );
  }

  // Função para traduzir tipos de recurso para português
  String _translateResourceType(ResourceType type) {
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
        return "SOS";
      case ResourceType.OTHER:
        return "Outro";
      case ResourceType.TIVA:
        return "TIVA";
      default:
        return type.toString().split('.').last;
    }
  }

  Widget _buildHCard(Resource resource, Color backgroundColor) {
    const int maxDescriptionLength = 90; // expandido para permitir até ~2 linhas

    String truncatedDescription = resource.description.length > maxDescriptionLength
        ? '${resource.description.substring(0, maxDescriptionLength)}...'
        : resource.description;

    // Emoji para cada tipo de recurso (incluindo TIVA)
    String emoji;
    switch (resource.type) {
      case ResourceType.ARTICLE:
        emoji = "📖";
        break;
      case ResourceType.VIDEO:
        emoji = "🎬";
        break;
      case ResourceType.PODCAST:
        emoji = "🎧";
        break;
      case ResourceType.PHRASE:
        emoji = "💬";
        break;
      case ResourceType.CARE:
        emoji = "💚";
        break;
      case ResourceType.EXERCISE:
        emoji = "🏋️";
        break;
      case ResourceType.RECIPE:
        emoji = "🍲";
        break;
      case ResourceType.MUSIC:
        emoji = "🎵";
        break;
      case ResourceType.SOS:
        emoji = "🚨";
        break;
      case ResourceType.OTHER:
        emoji = "🗂️";
        break;
      case ResourceType.TIVA:
        emoji = "🧠";
        break;
      default:
        emoji = "❓";
    }

    return Center(
      child: Container(
        width: 520, // aumenta a largura do card
        constraints: const BoxConstraints(minHeight: 140), // altura mínima, cresce conforme necessário
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.65), // reduz opacidade do fundo
          borderRadius: BorderRadius.circular(30),
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
                    maxLines: 2,
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
                          emoji,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _translateResourceType(resource.type),
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
            const SizedBox(width: 24),
          ],
        ),
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