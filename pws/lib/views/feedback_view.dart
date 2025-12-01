import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackButton extends StatelessWidget {
  final double bottom;
  final double right;
  const FeedbackButton({Key? key, this.bottom = 120, this.right = 16}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FloatingActionButton(
      heroTag: 'feedback_btn',
      backgroundColor: isDark ? Colors.teal[700] : Colors.teal,
      mini: true,
      onPressed: () => _openFeedbackSheet(context),
      child: const Icon(Icons.feedback, color: Colors.white),
    );
  }

  void _openFeedbackSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final messageController = TextEditingController();
    final emailController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(builder: (context, setState) {
            bool isSending = false;
            Future<void> send() async {
              if (!formKey.currentState!.validate()) return;
              setState(() => isSending = true);
              final user = FirebaseAuth.instance.currentUser;
              try {
                await FirebaseFirestore.instance.collection('feedback').add({
                  'uid': user?.uid,
                  'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  'message': messageController.text.trim(),
                  'page': ModalRoute.of(ctx)?.settings.name ?? '',
                  'timestamp': FieldValue.serverTimestamp(),
                });
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback verzonden, dank!')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fout bij verzenden: $e')));
                }
              } finally {
                if (context.mounted) setState(() => isSending = false);
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 8),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: messageController,
                        maxLines: 5,
                        minLines: 3,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Wat wil je ons vertellen?',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Voer een bericht in' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'E-mail (optioneel voor antwoord)',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuleren')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isSending ? null : send,
                      child: isSending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Verstuur'),
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }
}