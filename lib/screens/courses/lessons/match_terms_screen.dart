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

  // Track the visual state (border color, opacity) for each definition card.
  late List<Color> definitionBorderColors;
  late List<double> definitionOpacities;

  @override
  void initState() {
    super.initState();
    matchedDefinitions =
        List<String?>.filled(widget.question.flashcards.length, null);

    // Shuffle definitions.
    shuffledDefinitions = List<Flashcard>.from(widget.question.flashcards);
    shuffledDefinitions.shuffle();

    // Initialize border colors and opacities for each definition card.
    definitionBorderColors =
        List<Color>.filled(shuffledDefinitions.length, greyBorder);
    definitionOpacities = List<double>.filled(shuffledDefinitions.length, 1.0);
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
                // Left: Terms + DragTarget
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
                // Right: Draggable Definitions
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

  /// Instructions widget (can customize further).
  Widget _buildInstructions(BuildContext context) {
    return Container(
      width: double.infinity,
      child: const Text(
        "Drag the matching definitions to each term.",
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );
  }

  /// A card with a Term and a DragTarget area.
  /// We wrap it in a SizedBox (or ConstrainedBox) to enforce a uniform height.
  Widget _buildTermCard(String term, String? matchedDef, int termIndex) {
    return SizedBox(
      height: 150, // Fixed height for all term cards
      child: Card(
        color: Colors.grey[850],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DragTarget<String>(
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
            onAccept: (data) {
              final correctDefinition =
                  widget.question.flashcards[termIndex].definition;
              final isCorrect = (data == correctDefinition);

              // Find which item in the shuffled list was dragged
              final defIndex =
                  shuffledDefinitions.indexWhere((fc) => fc.definition == data);

              if (defIndex != -1) {
                setState(() {
                  if (isCorrect) {
                    // Mark the term as matched
                    matchedDefinitions[termIndex] = data;
                    // Highlight in green, then fade out that definition card
                    definitionBorderColors[defIndex] = Colors.green;

                    // Fade out after a short delay
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        definitionOpacities[defIndex] = 0.0;
                      });
                      // Remove from list after fade completes
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (defIndex < shuffledDefinitions.length) {
                          setState(() {
                            shuffledDefinitions.removeAt(defIndex);
                            definitionBorderColors.removeAt(defIndex);
                            definitionOpacities.removeAt(defIndex);
                          });
                        }
                      });
                    });
                  } else {
                    // Temporarily highlight in red, revert after a second
                    definitionBorderColors[defIndex] = Colors.red;
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        if (defIndex < definitionBorderColors.length) {
                          definitionBorderColors[defIndex] = greyBorder;
                        }
                      });
                    });
                  }
                });
              }
            },
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
        final definition = shuffledDefinitions[index].definition;
        return Draggable<String>(
          data: definition,
          // This is what appears under the finger while dragging.
          feedback: _buildDefinitionDragFeedback(definition, index),
          // Show a reduced opacity when the card is dragged away.
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildDefinitionCard(definition, index),
          ),
          child: _buildDefinitionCard(definition, index),
        );
      },
    );
  }

  /// Static card for a definition in the right column.
  /// Also wrapped in a SizedBox to enforce uniform height.
  Widget _buildDefinitionCard(String definition, int index) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: definitionOpacities[index],
      child: SizedBox(
        height: 150, // Fixed height for all definition cards
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: definitionBorderColors[index],
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: Colors.white,
          // margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                textAlign: TextAlign.center,
                definition,
                style: const TextStyle(
                    fontSize: 12, color: Color.fromARGB(174, 0, 0, 0)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget shown under the user's finger while dragging (full card).
  Widget _buildDefinitionDragFeedback(String definition, int index) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: 180, // Match your card width if desired
        height: 150, // Match your card height if desired
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
                    fontSize: 12, color: Color.fromARGB(174, 0, 0, 0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
