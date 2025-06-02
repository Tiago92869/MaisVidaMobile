import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:testtest/resources/fullscreen_video_page.dart';
import 'package:video_player/video_player.dart';
import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/services/favorite/favorite_service.dart';
import 'package:testtest/services/favorite/favorite_model.dart';
import 'package:testtest/resources/resource_feedback_page.dart';
import 'package:testtest/services/image/image_service.dart';
import 'package:testtest/services/video/video_repository.dart';
import 'package:testtest/services/audio/audio_repository.dart';
import 'package:audioplayers/audioplayers.dart';

class ResourceDetailPage extends StatefulWidget {
  final Resource resource;

  const ResourceDetailPage({Key? key, required this.resource})
      : super(key: key);

  @override
  _ResourceDetailPageState createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  final FavoriteService _favoriteService = FavoriteService();
  final ImageService _imageService = ImageService();
  final VideoRepository _videoRepository = VideoRepository();
  final AudioRepository _audioRepository = AudioRepository();
  final Map<String, AudioPlayer> _audioPlayers = {}; // Map to store audio players for each content
  final Map<String, bool> _audioLoadingStates = {}; // Map to track loading states for each content
  final Map<String, String?> _audioUrls = {}; // Map to store audio URLs for each content
  final Map<String, String?> _selectedOptionsByContent = {}; // Track selected options per content

  bool _isFavorite = false;
  bool _initialFavoriteStatus = false;
  bool _showFirstStarfish = Random().nextBool();

  final Map<String, String> _imageCache = {}; // Cache for all images
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  String? _selectedYesNo; // Track the selected option for YESNO content
  String? _selectedOption; // Track the selected option for SELECTONE content
  Set<String> _selectedOptions = {}; // Track the selected options for SELECTMULTI content
  bool _isAudioLoading = false;
  String? _currentAudioUrl;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _initializeVideoPlayer();
    _initializeImages(); // Prefetch all images
  }

  Future<void> _checkIfFavorite() async {
    try {
      final isFavorite = await _favoriteService.isFavorite(
        resourceId: widget.resource.id,
      );
      setState(() {
        _isFavorite = isFavorite;
        _initialFavoriteStatus = isFavorite;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    print('ResourceDetailPage: Initializing video player...');
    final Content? videoContent = widget.resource.contents.cast<Content?>().firstWhere(
      (content) => content?.type.toLowerCase() == 'video',
      orElse: () => null,
    );

    if (videoContent == null || videoContent.contentId == null) {
      print('ResourceDetailPage: No valid video content found.');
      setState(() {
        _isVideoInitialized = false;
      });
      return;
    }

    print('ResourceDetailPage: Video content found. ID: ${videoContent.contentId}');

    try {
      final file = await _videoRepository.downloadVideoFile(videoContent.contentId!);

      if (file != null && await file.exists()) {
        _videoController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
          }).catchError((error) {
            print('ResourceDetailPage: Error during video player initialization: $error');
            setState(() {
              _isVideoInitialized = false;
            });
          });
      } else {
        print('ResourceDetailPage: Video file does not exist or is not readable.');
        setState(() {
          _isVideoInitialized = false;
        });
      }
    } catch (e) {
      print('ResourceDetailPage: Error initializing video player: $e');
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  Future<void> _initializeImages() async {
    print('ResourceDetailPage: Initializing images...');
    final imageContents = widget.resource.contents
        .where((content) => content.type.toLowerCase() == 'image' && content.contentId != null)
        .toList();

    for (final content in imageContents) {
      try {
        final base64Image = await _imageService.getImageBase64(content.contentId!);
        _imageCache[content.contentId!] = base64Image; // Cache the image
        print('ResourceDetailPage: Image cached for content ID: ${content.contentId}');
      } catch (e) {
        print('ResourceDetailPage: Error fetching image for content ID: ${content.contentId}: $e');
      }
    }
  }

  @override
  void dispose() {
    // Dispose all audio players
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFavoriteStatus() async {
    setState(() {
      _isFavorite = !_isFavorite; // Toggle the favorite status locally
    });

    try {
      final favoriteInput = FavoriteInput(
        activities: [],
        resources: [widget.resource.id], // Pass the resource ID
      );

      // Call modifyFavorite with the appropriate `add` value
      await _favoriteService.modifyFavorite(favoriteInput, _isFavorite);
      print(
        _isFavorite
            ? 'Resource added to favorites.'
            : 'Resource removed from favorites.',
      );
    } catch (e) {
      print('Error updating favorite status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorite status.')),
      );

      // Revert the favorite status if the request fails
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ResourceDetailPage: Building UI...');
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
          // Add both starfish images
          Positioned(
            right: 80,
            top: -80,
            width: 400,
            height: 400,
            child: Opacity(
              opacity: 0.1,
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
              opacity: 0.1,
              child: Transform.rotate(
                angle: 0.5,
                child: Image.asset(
                  'assets/images/starfish1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Scrollable content
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
                          _buildResourceDetails(),
                          const SizedBox(height: 20),
                          Spacer(), // Push the following content to the bottom if there's extra space
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDateInfo("Created At", widget.resource.createdAt),
                              _buildDateInfo("Updated At", widget.resource.updatedAt),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResourceFeedbackPage(
                                      resourceId: widget.resource.id,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: const Color(0xFF0D1B2A),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
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

  Widget _buildResourceDetails() {
    final resource = widget.resource;

    // Sort contents by ascending order
    final sortedContents = List.of(resource.contents)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),

        // Title and Favorite Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                resource.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: _toggleFavoriteStatus, // Toggle the favorite status
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300), // Smooth transition for color change
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isFavorite ? Colors.yellow : Colors.transparent,
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                child: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? Colors.white : Colors.yellow,
                  size: 28, // Adjust size if needed
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Resource Type
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            resource.type.toString().split('.').last,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Resource Description
        Text(
          resource.description,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Inter",
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Divider Line
        const Divider(
          color: Colors.white24,
          thickness: 1,
        ),
        const SizedBox(height: 20),

        // Render contents in order
        for (final content in sortedContents) ...[
          if (content.type.toLowerCase() == 'text' && content.contentValue != null) ...[
            Center(
              child: Text(
                content.contentValue!,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Inter",
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else if (content.type.toLowerCase() == 'image' && content.contentId != null) ...[
            _buildCachedImage(content.contentId!),
          ] else if (content.type.toLowerCase() == 'video') ...[
            if (_isVideoInitialized && _videoController != null)
              Column(
                children: [
                  AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                  const SizedBox(height: 12),
                  VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Colors.redAccent,
                      bufferedColor: Colors.grey,
                      backgroundColor: Colors.white30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_5, color: Colors.white),
                        onPressed: () {
                          final currentPosition = _videoController!.value.position;
                          Duration newPosition = currentPosition - const Duration(seconds: 5);
                          if (newPosition < Duration.zero) newPosition = Duration.zero;
                          _videoController!.seekTo(newPosition);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_videoController!.value.isPlaying) {
                              _videoController!.pause();
                            } else {
                              _videoController!.play();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_5, color: Colors.white),
                        onPressed: () {
                          final currentPosition = _videoController!.value.position;
                          final maxPosition = _videoController!.value.duration;
                          Duration newPosition = currentPosition + const Duration(seconds: 5);
                          if (newPosition > maxPosition) newPosition = maxPosition;
                          _videoController!.seekTo(newPosition);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _videoController!.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _videoController!.setVolume(
                              _videoController!.value.volume > 0 ? 0 : 1,
                            );
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullscreenVideoPage(
                                videoController: _videoController!,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              )
            else if (!_isVideoInitialized)
              const Center(child: CircularProgressIndicator()),
          ] else if (content.type.toLowerCase() == 'phrase' && content.contentValue != null) ...[
            _buildPhraseContent(content.contentValue!),
          ] else if (content.type.toLowerCase() == 'yesno') ...[
            _buildYesNoContent(content),
          ] else if (content.type.toLowerCase() == 'selectone') ...[
            _buildSelectOneContent(content),
          ] else if (content.type.toLowerCase() == 'selectmulti') ...[
            _buildSelectMultiContent(content),
          ] else if (content.type.toLowerCase() == 'sound') ...[
            _buildSoundContent(content),
          ],
          const SizedBox(height: 30), // Space between contents
        ],
      ],
    );
  }

  Widget _buildCachedImage(String contentId) {
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget _buildDateInfo(String label, DateTime? date) {
    if (date == null) return const SizedBox.shrink();

    final formattedDate =
        "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formattedDate,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPhraseContent(String contentValue) {
    final parts = contentValue.split('\n'); // Split the string by \n
    final upperText = parts.isNotEmpty ? parts[0] : ''; // First line
    final lowerText = parts.length > 1 ? parts[1] : ''; // Second line

    return Center( // Center the entire content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center-align the text
        children: [
          Text(
            '"$upperText"', // Add quotes around the upper text
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center, // Center-align the text
          ),
          const SizedBox(height: 8), // Add spacing between lines
          Text(
            lowerText, // Add quotes around the lower text
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center, // Center-align the text
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
            fontSize: 16,
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
                  _selectedYesNo = _selectedYesNo == 'yes' ? null : 'yes'; // Allow deselect
                });
              },
              child: Container(
                width: 80, // Make it square
                height: 80, // Make it square
                decoration: BoxDecoration(
                  color: _selectedYesNo == 'yes'
                      ? Colors.green
                      : Colors.transparent, // Same as background
                  border: Border.all(
                    color: Colors.white, // White border
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8), // Slightly rounded corners
                ),
                child: Center(
                  child: const Text(
                    'Sim', // Change label to "Sim"
                    style: TextStyle(
                      color: Colors.white, // White text
                      fontWeight: FontWeight.bold, // Bold font
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedYesNo = _selectedYesNo == 'no' ? null : 'no'; // Allow deselect
                });
              },
              child: Container(
                width: 80, // Make it square
                height: 80, // Make it square
                decoration: BoxDecoration(
                  color: _selectedYesNo == 'no'
                      ? Colors.red
                      : Colors.transparent, // Same as background
                  border: Border.all(
                    color: Colors.white, // White border
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8), // Slightly rounded corners
                ),
                child: Center(
                  child: const Text(
                    'Não', // Change label to "Não"
                    style: TextStyle(
                      color: Colors.white, // White text
                      fontWeight: FontWeight.bold, // Bold font
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          opacity: _selectedYesNo == null ? 0.0 : 1.0, // Make text invisible when deselected
          duration: const Duration(milliseconds: 300),
          child: Text(
            _selectedYesNo == 'yes'
                ? (content.answerYes ?? '')
                : _selectedYesNo == 'no'
                    ? (content.answerNo ?? '')
                    : '',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectOneContent(Content content) {
    // Calculate the largest width and height
    final textSizes = content.multipleValue?.map((option) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: option,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          return textPainter.size;
        }).toList() ??
        [];

    final maxWidth = textSizes.isNotEmpty
        ? textSizes.map((size) => size.width).reduce((a, b) => a > b ? a : b)
        : 0.0;

    final maxHeight = textSizes.isNotEmpty
        ? textSizes.map((size) => size.height).reduce((a, b) => a > b ? a : b)
        : 0.0;

    if (content.multipleValue == null || content.multipleValue!.isEmpty) {
      // Special case: multipleValue is empty
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
                      isSelected ? null : content.contentValue; // Allow deselect
                });
              },
              child: Container(
                width: 180, // Set a fixed larger width
                height: 60, // Set a fixed larger height
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue
                      : Colors.transparent, // Highlight selected option
                  border: Border.all(
                    color: Colors.white, // White border
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                alignment: Alignment.center,
                child: Text(
                  content.contentValue ?? '',
                  style: const TextStyle(
                    fontSize: 16, // Slightly larger font size
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
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      );
    }

    // Default case: multipleValue is not empty
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            content.contentValue ?? '',
            style: const TextStyle(
              fontSize: 16,
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
                            isSelected ? null : option; // Allow deselect
                      });
                    },
                    child: Container(
                      width: maxWidth + 40, // Add padding to the width
                      height: maxHeight + 40, // Add padding to the height
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : Colors.transparent, // Highlight selected option
                        border: Border.all(
                          color: Colors.white, // White border
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8), // Rounded corners
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
    // Calculate the largest width and height
    final textSizes = content.multipleValue?.map((option) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: option,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          return textPainter.size;
        }).toList() ??
        [];

    final maxWidth = textSizes.isNotEmpty
        ? textSizes.map((size) => size.width).reduce((a, b) => a > b ? a : b)
        : 0.0;

    final maxHeight = textSizes.isNotEmpty
        ? textSizes.map((size) => size.height).reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Center( // Center the entire content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            content.contentValue ?? '',
            style: const TextStyle(
              fontSize: 16,
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
                          _selectedOptions.remove(option); // Deselect option
                        } else {
                          _selectedOptions.add(option); // Select option
                        }
                      });
                    },
                    child: Container(
                      width: maxWidth + 40, // Add padding to the width
                      height: maxHeight + 40, // Add padding to the height
                      decoration: BoxDecoration(
                        color: _selectedOptions.contains(option)
                            ? Colors.blue
                            : Colors.transparent, // Highlight selected options
                        border: Border.all(
                          color: Colors.white, // White border
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8), // Rounded corners
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
    final audioPlayer = _audioPlayers.putIfAbsent(content.id, () => AudioPlayer());
    final isLoading = _audioLoadingStates[content.id] ?? false;
    final audioUrl = _audioUrls[content.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          content.contentValue ?? '',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        isLoading
            ? const CircularProgressIndicator()
            : audioUrl == null
                ? ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _audioLoadingStates[content.id] = true;
                      });
                      try {
                        final audioFile = await _audioRepository.downloadAudioFile(content.contentId!);
                        if (audioFile != null) {
                          _audioUrls[content.id] = audioFile.path;
                          await audioPlayer.setSourceDeviceFile(audioFile.path);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to load audio.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error loading audio.')),
                        );
                      } finally {
                        setState(() {
                          _audioLoadingStates[content.id] = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Load Audio',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          audioPlayer.state == PlayerState.playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          if (audioPlayer.state == PlayerState.playing) {
                            await audioPlayer.pause();
                          } else {
                            await audioPlayer.resume();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop, color: Colors.white),
                        onPressed: () async {
                          await audioPlayer.stop();
                        },
                      ),
                    ],
                  ),
        const SizedBox(height: 16),
        StreamBuilder<Duration>(
          stream: audioPlayer.onPositionChanged,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration>(
              stream: audioPlayer.onDurationChanged,
              builder: (context, snapshot) {
                final duration = snapshot.data ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      value: position.inSeconds.toDouble(),
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) async {
                        await audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey,
                    ),
                    Text(
                      '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / '
                      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
