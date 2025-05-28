import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/models/question.dart';
import 'package:lumi_learn_app/utils/latex_text.dart';

class MatchTerms extends StatefulWidget {
  final Question question;

  const MatchTerms({Key? key, required this.question}) : super(key: key);

  @override
  _MatchTermsState createState() => _MatchTermsState();
}

class _MatchTermsState extends State<MatchTerms> {
  final CourseController courseController = Get.find<CourseController>();

  List<String?> matchedDefinitions = [];
  late List<Flashcard> shuffledDefinitions;
  late List<Color> definitionBorderColors;
  late List<double> definitionOpacities;
  late List<bool> definitionMatched;
  late List<Color> termBorderColors;
  late List<double> termOpacities;
  late List<bool> termMatched;

  bool _autoAdvanceTriggered = false;

  @override
  void initState() {
    super.initState();
    _initializeMatchTermsState();
  }

  void _initializeMatchTermsState() {
    setState(() {
      matchedDefinitions =
          List<String?>.filled(widget.question.flashcards.length, null);
      shuffledDefinitions = List<Flashcard>.from(widget.question.flashcards)
        ..shuffle();

      definitionBorderColors =
          List<Color>.filled(shuffledDefinitions.length, greyBorder);
      definitionOpacities =
          List<double>.filled(shuffledDefinitions.length, 1.0);
      definitionMatched = List<bool>.filled(shuffledDefinitions.length, false);

      termBorderColors =
          List<Color>.filled(widget.question.flashcards.length, greyBorder);
      termOpacities =
          List<double>.filled(widget.question.flashcards.length, 1.0);
      termMatched = List<bool>.filled(widget.question.flashcards.length, false);

      _autoAdvanceTriggered = false;
    });
  }

  @override
  void didUpdateWidget(covariant MatchTerms oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _resetState();
    }
  }

  void _resetState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMatchTermsState();
    });
  }

  bool allMatched() => matchedDefinitions.every((def) => def != null);

  bool hasNotch(BuildContext context) {
    return MediaQuery.of(context).padding.top > 20;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final bool deviceHasNotch = hasNotch(context);
    final double topPadding = isTablet ? 70.0 : (deviceHasNotch ? 0.0 : 50.0);
    final double textSize = isTablet ? 28.0 : 18.0;
    final double defTextSize = isTablet ? 22.0 : 12.0;
    final double popupTextSize = isTablet ? 30.0 : 20.0;
    final double cardHeight = isTablet ? 220.0 : 150.0;

    if (allMatched() && !_autoAdvanceTriggered) {
      _autoAdvanceTriggered = true;
      Future.delayed(const Duration(seconds: 1), () {
        courseController.nextQuestion();
        _autoAdvanceTriggered = false;
      });
    }

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, topPadding, 16.0, 0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            _buildInstructions(isTablet),
            const Divider(height: 60),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.question.flashcards.length,
                      itemBuilder: (context, index) {
                        final term = widget.question.flashcards[index].term;
                        final matchedDef = matchedDefinitions[index];
                        return _buildTermCard(
                            term, matchedDef, index, textSize, cardHeight);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                      child: _buildDefinitionsColumn(
                          defTextSize, popupTextSize, cardHeight)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(bool isTablet) {
    return Column(
      children: [
        Text(
          "Drag the matching definitions to each term",
          style:
              TextStyle(fontSize: isTablet ? 20.0 : 16.0, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap on a definition to expand it",
          style: TextStyle(
              fontSize: isTablet ? 18.0 : 14.0,
              color: const Color.fromARGB(167, 158, 158, 158)),
        ),
      ],
    );
  }

  Widget _buildTermCard(String term, String? matchedDef, int termIndex,
      double textSize, double cardHeight) {
    if (termMatched[termIndex]) return SizedBox(height: cardHeight);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: termOpacities[termIndex],
      child: SizedBox(
        height: cardHeight,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: termBorderColors[termIndex]),
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DragTarget<Flashcard>(
              builder: (context, candidateData, rejectedData) {
                return Center(
                  child: SmartText(
                    term,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                    align: TextAlign.center,
                  ),
                );
              },
              onWillAccept: (data) => true,
              onAccept: (acceptedFlashcard) {
                final correctDefinition =
                    widget.question.flashcards[termIndex].definition;
                final isCorrect =
                    acceptedFlashcard.definition == correctDefinition;

                setState(() {
                  if (isCorrect) {
                    courseController.playSmallCorrectSound();
                    matchedDefinitions[termIndex] =
                        acceptedFlashcard.definition;
                    termBorderColors[termIndex] = Colors.green;
                  } else {
                    termBorderColors[termIndex] = Colors.red;
                  }
                });

                if (isCorrect) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() => termOpacities[termIndex] = 0.0);
                    Future.delayed(const Duration(milliseconds: 300),
                        () => setState(() => termMatched[termIndex] = true));
                  });
                } else {
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() => termBorderColors[termIndex] = greyBorder);
                  });
                }

                final defIndex = shuffledDefinitions
                    .indexWhere((fc) => fc == acceptedFlashcard);
                if (defIndex != -1) {
                  setState(() {
                    definitionBorderColors[defIndex] =
                        isCorrect ? Colors.green : Colors.red;
                  });
                  if (isCorrect) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() => definitionOpacities[defIndex] = 0.0);
                      Future.delayed(
                          const Duration(milliseconds: 300),
                          () => setState(
                              () => definitionMatched[defIndex] = true));
                    });
                  } else {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (defIndex < definitionBorderColors.length) {
                        setState(() =>
                            definitionBorderColors[defIndex] = greyBorder);
                      }
                    });
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefinitionsColumn(
      double defTextSize, double popupTextSize, double cardHeight) {
    return ListView.builder(
      itemCount: shuffledDefinitions.length,
      itemBuilder: (context, index) {
        if (definitionMatched[index]) return SizedBox(height: cardHeight);
        final flashcard = shuffledDefinitions[index];
        return Draggable<Flashcard>(
          data: flashcard,
          feedback: _buildDefinitionDragFeedback(
              flashcard, index, defTextSize, cardHeight),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildDefinitionCard(
                flashcard.definition, index, defTextSize, cardHeight),
          ),
          child: _buildDefinitionCard(
              flashcard.definition, index, defTextSize, cardHeight),
        );
      },
    );
  }

  Widget _buildDefinitionCard(
      String definition, int index, double textSize, double cardHeight) {
    return GestureDetector(
      onTap: () => _showDefinitionPopup(definition, textSize + 8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: definitionOpacities[index],
        child: SizedBox(
          height: cardHeight,
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: definitionBorderColors[index]),
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SmartText(
                  definition,
                  style: TextStyle(
                    fontSize: textSize,
                    color: const Color.fromARGB(174, 0, 0, 0),
                  ),
                  align: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDefinitionPopup(String definition, double popupTextSize) {
    showDialog(
      context: context,
      builder: (_) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Dialog(
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: greyBorder, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SmartText(
                      definition,
                      style: TextStyle(
                        fontSize: popupTextSize,
                        color: const Color.fromARGB(174, 0, 0, 0),
                      ),
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefinitionDragFeedback(
      Flashcard flashcard, int index, double textSize, double cardHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.48; // 40% of screen width

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: definitionBorderColors[index], width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SmartText(
                flashcard.definition,
                style: TextStyle(
                  fontSize: textSize,
                  color: const Color.fromARGB(174, 0, 0, 0),
                ),
                align: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
