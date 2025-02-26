import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/widgets/app_scaffold.dart';

class MatchTerms extends StatefulWidget {
  final Question question;

  const MatchTerms({Key? key, required this.question}) : super(key: key);

  @override
  _MatchTermsState createState() => _MatchTermsState();
}

class _MatchTermsState extends State<MatchTerms> {
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

  bool allMatched() {
    return matchedDefinitions.every((def) => def != null);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          _buildInstructions(context),
          const Divider(),
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
                const SizedBox(width: 16),
                // Right: Draggable Definitions (fixed positions)
                Expanded(
                  child: _buildDefinitionsColumn(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (allMatched())
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All terms matched! Good job!'),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text("Continue"),
            ),
        ],
      ),
    );
  }

  /// Instructions widget.
  Widget _buildInstructions(BuildContext context) {
    return Container(
      width: double.infinity,
      child: const Text(
        "Drag the matching definitions to each term.",
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );
  }

  /// Build a term card that is also a DragTarget.
  Widget _buildTermCard(String term, String? matchedDef, int termIndex) {
    // If term is already matched, return a placeholder to keep spacing.
    if (termMatched[termIndex]) {
      return SizedBox(height: 150);
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
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: Colors.grey[850],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DragTarget<Flashcard>(
              builder: (context, candidateData, rejectedData) {
                return Align(
                  alignment: Alignment.center,
                  child: Text(
                    term,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: definitionOpacities[index],
      child: SizedBox(
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
                definition,
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
