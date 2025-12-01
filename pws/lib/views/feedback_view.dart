import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackButton extends StatelessWidget {
  final double bottom;
  final double right;

  const FeedbackButton({Key? key, this.bottom = 120, this.right = 16})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return FloatingActionButton(
      heroTag: 'feedback_btn',
      backgroundColor: isDarkMode ? Colors.teal[700] : Colors.teal,
      mini: true,
      onPressed: () => _openFeedbackSheet(context),
      child: Icon(Icons.feedback, color: Colors.white),
    );
  }

  void _openFeedbackSheet(BuildContext context) {
    final outerContext = context;
    final formKey = GlobalKey<FormState>();
    final messageController = TextEditingController();
    final emailController = TextEditingController();

    int rating = 0;
    bool isSending = false;
    String selectedType = 'bug';


    showModalBottomSheet<void>(
      context: outerContext,
      isScrollControlled: true,
backgroundColor: Theme.of(outerContext).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final isDarkMode = Theme.of(ctx).brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (innerCtx, setState) {
              Future<void> send() async {
                if (!formKey.currentState!.validate()) return;

                setState(() => isSending = true);

                try {
                  final user = FirebaseAuth.instance.currentUser;

                  await FirebaseFirestore.instance
                      .collection('feedback')
                      .add({
                    'uid': user?.uid,
                    'email': emailController.text.trim().isEmpty
                        ? null
                        : emailController.text.trim(),
                    'message': messageController.text.trim(),
                    'rating': rating,
                    'type': selectedType,
                    'timestamp': FieldValue.serverTimestamp(),
                    'platform': Theme.of(outerContext).platform.name,
                  });

                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(outerContext).showSnackBar(
                      const SnackBar(
                        content: Text('Bedankt voor je feedback!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(outerContext).showSnackBar(
                      SnackBar(
                        content: Text('Fout bij verzenden: $e'),
                      ),
                    );
                  }
                } finally {
                  if (ctx.mounted) setState(() => isSending = false);
                }
              }

                            Widget buildTypeChip(String value, String label) {
                final bool selected = selectedType == value;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => selectedType = value);
                  },
                );
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    Text(
                      'Geef je feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// ⭐ Rating
                    Row(
                      children: List.generate(5, (i) {
                        return IconButton(
                          onPressed: () => setState(() => rating = i + 1),
                          icon: Icon(
                            Icons.star,
                            color: i < rating ? Colors.amber : Colors.grey[500],
                          ),
                        );
                      }),
                    ),

                                        const SizedBox(height: 8),

                    // 4 opties op een rij
                    Wrap(
                      spacing: 8,
                      children: [
                        buildTypeChip('bug', 'Bug'),
                        buildTypeChip('feature', 'Nieuwe functie'),
                        buildTypeChip('layout', 'Layout'),
                        buildTypeChip('other', 'Anders'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: messageController,
                            maxLines: 5,
                            minLines: 3,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Wat wil je ons vertellen?',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Voer een bericht in'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'E-mail (optioneel)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Annuleren'),
                        ),
                        ElevatedButton(
                          onPressed: isSending ? null : send,
                          child: isSending
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                )
                              : const Text('Versturen'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
