import 'package:flutter/material.dart';
import 'package:mentara/services/favorite/favorite_service.dart';
import 'package:mentara/services/favorite/favorite_model.dart';
import 'package:mentara/services/activity/activity_model.dart';
import 'package:mentara/services/resource/resource_model.dart';
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:mentara/services/image/image_service.dart';
import 'package:audioplayers/audioplayers.dart';

class ActivityDetailsPage extends StatefulWidget {
  final Activity activity;

  const ActivityDetailsPage({Key? key, required this.activity})
      : super(key: key);

  @override
  _ActivityDetailsPageState createState() => _ActivityDetailsPageState();
}

class _ActivityDetailsPageState extends State<ActivityDetailsPage> {
  final FavoriteService _favoriteService = FavoriteService();

  bool _isFavorite = false;
  int _currentResourceIndex = 0;
  final ImageService _imageService = ImageService();
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, String> _imageCache = {};
  VideoPlayerController? _videoController;
  String? _selectedYesNo;
  final Set<String> _selectedOptions = {};
  final Map<String, String?> _selectedOptionsByContent = {};

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _initializeImages();
    _initializeVideoPlayer();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final isFavorite = await _favoriteService.isFavorite(
        activityId: widget.activity.id,
      );
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao verificar o estado dos favoritos. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleFavoriteStatus() async {
    try {
      final favoriteInput = FavoriteInput(
        activities: [widget.activity.id],
        resources: [],
      );
      await _favoriteService.modifyFavorite(favoriteInput, !_isFavorite);
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao atualizar o estado favorito.')),
      );
    }
  }

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
      }
  }

  Future<void> _initializeImages() async {
    final resources = widget.activity.resources ?? [];
    if (_currentResourceIndex >= resources.length) return;
    final resource = resources[_currentResourceIndex];
    final imageContents = resource.contents
        .where((content) => content.type.toLowerCase() == 'image' && content.contentId != null)
        .toList();
    for (final content in imageContents) {
      try {
        final base64Image = await _imageService.getImageBase64(content.contentId!);
        _imageCache[content.contentId!] = base64Image;
      } catch (_) {}
    }
  }

  Future<void> _initializeVideoPlayer() async {
    final resources = widget.activity.resources ?? [];
    if (_currentResourceIndex >= resources.length) return;
    final resource = resources[_currentResourceIndex];
    final Content? videoContent = resource.contents.cast<Content?>().firstWhere(
      (content) => content?.type.toLowerCase() == 'video',
      orElse: () => null,
    );
    if (videoContent == null || videoContent.contentId == null) {
      setState(() {});
      return;
    }
    try {
      setState(() {});
    } catch (_) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final resources = activity.resources ?? [];
    final currentResource = resources.isNotEmpty ? resources[_currentResourceIndex] : null;

    final uniqueResourceTypes = <ResourceType, Resource>{};
    for (final resource in resources) {
      uniqueResourceTypes.putIfAbsent(resource.type, () => resource);
    }

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
          Positioned(
            right: 80,
            top: -80,
            width: 400,
            height: 400,
            child: Opacity(
              opacity: 0.05,
              child: Transform.rotate(
                angle: 0.7,
                child: Image.asset(
                  'assets/images/starfish2.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: 100,
            top: 450,
            width: 400,
            height: 400,
            child: Opacity(
              opacity: 0.05,
              child: Transform.rotate(
                angle: 0.5,
                child: Image.asset(
                  'assets/images/starfish1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  activity.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _toggleFavoriteStatus,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isFavorite ? Colors.yellow : Colors.transparent,
                                    border: Border.all(color: Colors.yellow, width: 2),
                                  ),
                                  child: Icon(
                                    _isFavorite ? Icons.star : Icons.star_border,
                                    color: _isFavorite ? Colors.white : Colors.yellow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (uniqueResourceTypes.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: uniqueResourceTypes.values
                                  .map((resource) => Container(
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
                                              style: const TextStyle(fontSize: 18),
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
                                      ))
                                  .toList(),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            activity.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "Inter",
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            color: Colors.white24,
                            thickness: 1,
                          ),
                          const SizedBox(height: 20),
                          if (currentResource == null)
                            const Center(
                              child: Text(
                                "Nenhum recurso disponível",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          else
                            _buildResourceContents(currentResource),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_currentResourceIndex > 0)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentResourceIndex--;
                                      _initializeImages();
                                      _initializeVideoPlayer();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Anterior',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                              if (_currentResourceIndex < resources.length - 1)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _currentResourceIndex++;
                                      _initializeImages();
                                      _initializeVideoPlayer();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Próximo',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Criado em",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activity.createdAt != null
                                        ? "${activity.createdAt!.day.toString().padLeft(2, '0')}-${activity.createdAt!.month.toString().padLeft(2, '0')}-${activity.createdAt!.year}"
                                        : "-",
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                              if (resources.isNotEmpty && _currentResourceIndex == resources.length - 1)
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF0D1B2A),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Terminar',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 120),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Recursos",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${resources.isEmpty ? 0 : _currentResourceIndex + 1} de ${resources.length}",
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceContents(Resource resource) {
    final sortedContents = List.of(resource.contents)
      ..sort((a, b) => a.order.compareTo(b.order));
    if (sortedContents.isEmpty) {
      return const Center(
        child: Text(
          "Sem conteúdos neste recurso.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedContents.map((content) {
        switch (content.type.toLowerCase()) {
          case 'text':
            return _buildTextContent(content.contentValue);
          case 'image':
            return _buildCachedImage(content.contentId);
          case 'phrase':
            return _buildPhraseContent(content.contentValue);
          case 'yesno':
            return _buildYesNoContent(content);
          case 'selectone':
            return _buildSelectOneContent(content);
          case 'selectmulti':
            return _buildSelectMultiContent(content);
          case 'sound':
            return _buildSoundContent(content);
          case 'video':
            return _buildVideoContent(content);
          default:
            return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

  Widget _buildTextContent(String? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildCachedImage(String? contentId) {
    if (contentId == null) return const SizedBox.shrink();
    if (_imageCache.containsKey(contentId)) {
      final base64Image = _imageCache[contentId]!;
      return Center(
        child: SizedBox(
          width: 150,
          height: 150,
          child: Image.memory(
            base64Decode(base64Image),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildPhraseContent(String? contentValue) {
    if (contentValue == null) return const SizedBox.shrink();
    final parts = contentValue.split('\n');
    final upperText = parts.isNotEmpty ? parts[0] : '';
    final lowerText = parts.length > 1 ? parts[1] : '';
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '"$upperText"',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            lowerText,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoContent(Content content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          content.contentValue ?? '',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedYesNo = _selectedYesNo == 'yes' ? null : 'yes';
                });
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _selectedYesNo == 'yes'
                      ? Colors.green
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Sim',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedYesNo = _selectedYesNo == 'no' ? null : 'no';
                });
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _selectedYesNo == 'no'
                      ? Colors.red
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Não',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          opacity: _selectedYesNo == null ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Text(
            _selectedYesNo == 'yes'
                ? (content.answerYes ?? '')
                : _selectedYesNo == 'no'
                    ? (content.answerNo ?? '')
                    : '',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectOneContent(Content content) {
    final textSizes = content.multipleValue?.map((option) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: option,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          return textPainter.size;
        }).toList() ?? [];
    final maxWidth = textSizes.isNotEmpty
        ? textSizes.map((size) => size.width).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final maxHeight = textSizes.isNotEmpty
        ? textSizes.map((size) => size.height).reduce((a, b) => a > b ? a : b)
        : 0.0;
    if (content.multipleValue == null || content.multipleValue!.isEmpty) {
      final isSelected = _selectedOptionsByContent[content.id] == content.contentValue;
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedOptionsByContent[content.id] =
                      isSelected ? null : content.contentValue;
                });
              },
              child: Container(
                width: 180,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  content.contentValue ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isSelected && content.answerYes != null)
              Text(
                content.answerYes!,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            content.contentValue ?? '',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: content.multipleValue?.map((option) {
                  final isSelected = _selectedOptionsByContent[content.id] == option;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOptionsByContent[content.id] =
                            isSelected ? null : option;
                      });
                    },
                    child: Container(
                      width: maxWidth + 40,
                      height: maxHeight + 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList() ??
                [],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectMultiContent(Content content) {
    final textSizes = content.multipleValue?.map((option) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: option,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          return textPainter.size;
        }).toList() ?? [];
    final maxWidth = textSizes.isNotEmpty
        ? textSizes.map((size) => size.width).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final maxHeight = textSizes.isNotEmpty
        ? textSizes.map((size) => size.height).reduce((a, b) => a > b ? a : b)
        : 0.0;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            content.contentValue ?? '',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: content.multipleValue?.map((option) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedOptions.contains(option)) {
                          _selectedOptions.remove(option);
                        } else {
                          _selectedOptions.add(option);
                        }
                      });
                    },
                    child: Container(
                      width: maxWidth + 40,
                      height: maxHeight + 40,
                      decoration: BoxDecoration(
                        color: _selectedOptions.contains(option)
                            ? Colors.blue
                            : Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        option,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList() ??
                [],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundContent(Content content) {
    _audioPlayers.putIfAbsent(content.id, () => AudioPlayer());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          content.contentValue ?? '',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Carregar áudio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent(Content content) {
    return const Center(
      child: Text(
        "Conteúdo de vídeo",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
