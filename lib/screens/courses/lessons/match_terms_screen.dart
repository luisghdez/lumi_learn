import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
import 'package:lumi_learn_app/widgets/app_scaffold.dart';

class MatchTerms extends StatefulWidget {
  final Question question;

  const MatchTerms({Key? key, required this.question}) : super(key: key);

  @override
  _MatchTermsState createState() => _MatchTermsState();
}

class _MatchTermsState extends State<MatchTerms> {
  final CourseController courseController = Get.find<CourseController>();

  // For each term index, store the matched definition (if any).
  late List<String?> matchedDefinitions;

  // Definitions on the right side, shuffled.
  late List<Flashcard> shuffledDefinitions;

  // For definition cards.
  late List<Color> definitionBorderColors;
  late List<double> definitionOpacities;
  late List<bool> definitionMatched;

  // For term cards.
  late List<Color> termBorderColors;
  late List<double> termOpacities;
  late List<bool> termMatched;

  @override
  void initState() {
    super.initState();
    matchedDefinitions =
        List<String?>.filled(widget.question.flashcards.length, null);

    // Shuffle definitions.
    shuffledDefinitions = List<Flashcard>.from(widget.question.flashcards);
    shuffledDefinitions.shuffle();

    // Initialize definition card states as growable lists.
    definitionBorderColors = List<Color>.filled(
      shuffledDefinitions.length,
      greyBorder,
      growable: true,
    );
    definitionOpacities = List<double>.filled(
      shuffledDefinitions.length,
      1.0,
      growable: true,
    );
    definitionMatched = List<bool>.filled(
      shuffledDefinitions.length,
      false,
      growable: true,
    );

    // Initialize term card states as growable lists.
    termBorderColors = List<Color>.filled(
      widget.question.flashcards.length,
      greyBorder,
      growable: true,
    );
    termOpacities = List<double>.filled(
      widget.question.flashcards.length,
      1.0,
      growable: true,
    );
    termMatched = List<bool>.filled(
      widget.question.flashcards.length,
      false,
      growable: true,
    );
  }

  @override
  void didUpdateWidget(covariant MatchTerms oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _resetState();
    }
  }

  bool allMatched() {
    return matchedDefinitions.every((def) => def != null);
  }

  void _resetState() {
    setState(() {
      matchedDefinitions =
          List<String?>.filled(widget.question.flashcards.length, null);
      shuffledDefinitions = List<Flashcard>.from(widget.question.flashcards);
      shuffledDefinitions.shuffle();

      definitionBorderColors = List<Color>.filled(
        shuffledDefinitions.length,
        greyBorder,
        growable: true,
      );
      definitionOpacities = List<double>.filled(
        shuffledDefinitions.length,
        1.0,
        growable: true,
      );
      definitionMatched = List<bool>.filled(
        shuffledDefinitions.length,
        false,
        growable: true,
      );

      termBorderColors = List<Color>.filled(
        widget.question.flashcards.length,
        greyBorder,
        growable: true,
      );
      termOpacities = List<double>.filled(
        widget.question.flashcards.length,
        1.0,
        growable: true,
      );
      termMatched = List<bool>.filled(
        widget.question.flashcards.length,
        false,
        growable: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              _buildInstructions(context),
              const Divider(height: 60),
              Expanded(
                child: Row(
                  children: [
                    // Left: Term cards with DragTarget.
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.question.flashcards.length,
                        itemBuilder: (context, index) {
                          final term = widget.question.flashcards[index].term;
                          final matchedDef = matchedDefinitions[index];
                          return _buildTermCard(term, matchedDef, index);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Right: Draggable Definitions (fixed positions)
                    Expanded(
                      child: _buildDefinitionsColumn(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (allMatched()) ...[
                SizedBox(
                  child: NextButton(
                    onPressed: () {
                      courseController.nextQuestion();
                      _resetState();
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ]
            ],
          ),
        ),
      ),
    );
  }

  /// Instructions widget.
  Widget _buildInstructions(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Drag the matching definitions to each term",
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        SizedBox(height: 8),
        Text(
          "Tap on a definition to expand it",
          style: TextStyle(
              fontSize: 14.0, color: Color.fromARGB(167, 158, 158, 158)),
        ),
      ],
    );
  }

  /// Build a term card that is also a DragTarget.
  Widget _buildTermCard(String term, String? matchedDef, int termIndex) {
    // If term is already matched, return a placeholder to keep spacing.
    if (termMatched[termIndex]) {
      return const SizedBox(height: 150);
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: termOpacities[termIndex],
      child: SizedBox(
        height: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: termBorderColors[termIndex],
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          // color: Colors.grey[1000],
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DragTarget<Flashcard>(
              builder: (context, candidateData, rejectedData) {
                return Align(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    term,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),
                );
              },
              onWillAccept: (data) => true,
              onAccept: (acceptedFlashcard) {
                final correctDefinition =
                    widget.question.flashcards[termIndex].definition;
                final isCorrect =
                    (acceptedFlashcard.definition == correctDefinition);

                // Update term card's visual state.
                setState(() {
                  if (isCorrect) {
                    termBorderColors[termIndex] = Colors.green;
                    matchedDefinitions[termIndex] =
                        acceptedFlashcard.definition;
                  } else {
                    termBorderColors[termIndex] = Colors.red;
                  }
                });

                if (isCorrect) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                      termOpacities[termIndex] = 0.0;
                    });
                    Future.delayed(const Duration(milliseconds: 300), () {
                      setState(() {
                        termMatched[termIndex] = true;
                      });
                    });
                  });
                } else {
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      termBorderColors[termIndex] = greyBorder;
                    });
                  });
                }

                // Update the corresponding definition card.
                final defIndex = shuffledDefinitions
                    .indexWhere((fc) => fc == acceptedFlashcard);
                if (defIndex != -1) {
                  setState(() {
                    if (isCorrect) {
                      definitionBorderColors[defIndex] = Colors.green;
                    } else {
                      definitionBorderColors[defIndex] = Colors.red;
                    }
                  });
                  if (isCorrect) {
                    final localIndex = defIndex;
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        definitionOpacities[localIndex] = 0.0;
                      });
                      Future.delayed(const Duration(milliseconds: 300), () {
                        setState(() {
                          definitionMatched[localIndex] = true;
                        });
                      });
                    });
                  } else {
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        if (defIndex < definitionBorderColors.length) {
                          definitionBorderColors[defIndex] = greyBorder;
                        }
                      });
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

  /// Build the column of draggable definition cards.
  Widget _buildDefinitionsColumn() {
    return ListView.builder(
      itemCount: shuffledDefinitions.length,
      itemBuilder: (context, index) {
        // If this definition card has been matched, return a placeholder.
        if (definitionMatched[index]) {
          return SizedBox(height: 150);
        } else {
          final flashcard = shuffledDefinitions[index];
          final definition = flashcard.definition;
          return Draggable<Flashcard>(
            data: flashcard,
            feedback: _buildDefinitionDragFeedback(flashcard, index),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildDefinitionCard(definition, index),
            ),
            child: _buildDefinitionCard(definition, index),
          );
        }
      },
    );
  }

  /// Static card for a definition.
  Widget _buildDefinitionCard(String definition, int index) {
    return GestureDetector(
      onTap: () {
        _showDefinitionPopup(definition);
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: definitionOpacities[index],
        child: SizedBox(
          height: 150,
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: definitionBorderColors[index],
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  definition,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(174, 0, 0, 0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to display the definition in a popup dialog.
  void _showDefinitionPopup(String definition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: greyBorder, // Match border color
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.white, // Match definition card color
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  definition,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20, // Slightly larger for readability
                    color: Color.fromARGB(174, 0, 0, 0), // Match text color
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Widget shown under the user's finger while dragging a definition.
  Widget _buildDefinitionDragFeedback(Flashcard flashcard, int index) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 180,
        height: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: definitionBorderColors[index],
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                textAlign: TextAlign.center,
                flashcard.definition,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(174, 0, 0, 0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
