import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mentara/services/journey/journey_service.dart';
import 'package:mentara/services/journey/journey_model.dart';
import 'journey_detail_page.dart';

class JourneyPage extends StatefulWidget {
  const JourneyPage({Key? key}) : super(key: key);

  @override
  _JourneyPageState createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  final JourneyService _journeyService = JourneyService();

  // State variables
  List<JourneySimpleUser> _journeys = [];
  bool _isLoading = false;

  final List<Color> _journeyColors = [
    const Color(0xFF9CC5FF),
    const Color(0xFF6E6AE8),
    const Color(0xFF005FE7),
    const Color(0xFFBBA6FF),
  ];

  @override
  void initState() {
    super.initState();
    _fetchJourneys();
  }

  Future<void> _fetchJourneys() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final journeys = await _journeyService.getAllJourneys();
      setState(() {
        _journeys = journeys;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao procurar as jornadas. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startJourneyAndNavigate(String journeyId) async {
    try {
      final journeyDetails = await _journeyService.startJourneyForUser(journeyId);

      // Navigate to the JourneyDetailPage with the fetched details and isNewJourney flag
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JourneyDetailPage(
            journey: journeyDetails,
            isNewJourney: true, // Indicate this is a newly started journey
          ),
        ),
      );

      // Refresh the journeys list when returning
      _fetchJourneys();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao iniciar a jornada. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToJourneyDetails(String journeyId, {bool isStarting = false}) async {
    if (isStarting) {
      await _startJourneyAndNavigate(journeyId);
      return;
    }

    try {
      final journeyDetails = await _journeyService.getJourneyDetails(journeyId);

      // Navigate to the JourneyDetailPage without isNewJourney flag
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JourneyDetailPage(
            journey: journeyDetails,
            isNewJourney: false, // Indicate this is not a newly started journey
          ),
        ),
      );

      // Refresh the journeys list when returning
      _fetchJourneys();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Falha ao obter os detalhes da jornada. Tente novamente."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildJourneyCard(JourneySimpleUser journey, Color backgroundColor) {
    final double progress = journey.completedQuantity / journey.resourceQuantity;
    final bool isComplete = progress >= 1.0;

    return Container(
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.65),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with a maximum of 2 lines
          Text(
            journey.title,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: "Poppins",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2, // Limit the title to a maximum of 2 lines
            overflow: TextOverflow.ellipsis, // Add ellipsis if it overflows
          ),
          const SizedBox(
            height: 30,
          ), // Increased spacing between title and description
          // Description with a maximum of 3 lines
          Text(
            journey.description,
            overflow: TextOverflow.ellipsis,
            maxLines: 4, // Limit the description to a maximum of 3 lines
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20), // Increased spacing before the progress bar
          Text(
            "${(progress * 100).toStringAsFixed(0)}% Concluído",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5), // Small spacing between text and progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.yellow : Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isComplete
                    ? () {
                      }
                    : null,
                child: Icon(
                  Icons.star,
                  color: isComplete ? Colors.yellow : Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await _navigateToJourneyDetails(journey.id, isStarting: !journey.started);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: backgroundColor,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                journey.started ? "Continuar" : "Começar",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showInfoDialog() async {
    final ScrollController scrollController = ScrollController();
    bool atBottom = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            scrollController.addListener(() {
              if (!scrollController.hasClients) return;
              final maxScroll = scrollController.position.maxScrollExtent;
              final currentScroll = scrollController.offset;
              final isAtBottom = (currentScroll >= maxScroll - 2);
              if (isAtBottom != atBottom) {
                setState(() {
                  atBottom = isAtBottom;
                });
              }
            });
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
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
child: const Text(
  "Esta é a janela das Jornadas, onde pode ver as jornadas criadas para o ajudar.\n\n"
  "Em cada jornada, há vários recursos para realizar, organizados por dia.\n"
  "  - O primeiro dia está disponível para começar.\n"
  "  - Ao completar um dia, o dia seguinte será desbloqueado para o dia seguinte.\n"
  "  - Cada dia que completar, receberá um prémio na forma de uma imagem.\n\n"
  "Quando terminar toda a jornada, receberá um prémio final.\n"
  "Pode consultar este prémio no canto superior esquerdo do ecrã.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (!atBottom) ...[
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 30,
                        child: IgnorePointer(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF0D1B2A),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 6,
                        child: IgnorePointer(
                          child: Center(
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white54,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
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
      },
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
                  colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Info icon on the left side (same position as in menu)
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
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Center(
                child: Text(
                  "Jornadas",
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: "Poppins",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        await _fetchJourneys(); // Refresh the list
                      },
                      child: _journeys.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhuma jornada criada",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "Poppins",
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              itemCount: _journeys.length + 1, // Add 1 for the SizedBox
                              itemBuilder: (context, index) {
                                if (index < _journeys.length) {
                                  final journey = _journeys[index];
                                  final backgroundColor =
                                      _journeyColors[index % _journeyColors.length];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 20,
                                    ),
                                    child: _buildJourneyCard(
                                      journey,
                                      backgroundColor,
                                    ),
                                  );
                                } else {
                                  return const SizedBox(
                                    height: 60,
                                  ); // Add spacing at the end
                                }
                              },
                            ),
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}