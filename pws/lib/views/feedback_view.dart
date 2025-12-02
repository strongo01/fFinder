import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackButton extends StatelessWidget {
  final double bottom; // afstand vanaf de onderkant
  final double right;     // afstand vanaf de rechterkant

  const FeedbackButton({Key? key, this.bottom = 120, this.right = 16})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.teal[700]! : Colors.teal;

    return FloatingActionButton(
      heroTag: 'feedback_btn',
      backgroundColor: baseColor.withOpacity(0.7),
      mini: true,
      onPressed: () => _openFeedbackSheet(context),
      child: Icon(Icons.feedback, color: Colors.white),
    );
  }

  void _openFeedbackSheet(BuildContext context) async {
    // Maak de functie async
    final outerContext = context;
    final formKey = GlobalKey<FormState>();
    final messageController = TextEditingController();
    final emailController = TextEditingController();

    int rating = 0;
    bool isSending = false;
    String selectedType = 'bug';

    // Controleer of de gebruiker een admin is
    final user = FirebaseAuth.instance.currentUser;
    bool isAdmin = false;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        isAdmin = userDoc.data()?['admin'] ?? false;
      } catch (e) {
        print("Kon admin status niet controleren: $e");
      }
    }

    showModalBottomSheet<void>( // Voeg het return type toe
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
            builder: (innerCtx, setState) { // Gebruik innerCtx voor de builder context. dat betekent dat we outerContext kunnen gebruiken voor snackbar etc.
              Future<void> send() async {
                if (!formKey.currentState!.validate()) return;

                setState(() => isSending = true);

                try {
                  final user = FirebaseAuth.instance.currentUser;

                  await FirebaseFirestore.instance.collection('feedback').add({
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

                  if (ctx.mounted) { // Controleer of de context nog gemount is
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
                      SnackBar(content: Text('Fout bij verzenden: $e')),
                    );
                  }
                } finally {
                  if (ctx.mounted) setState(() => isSending = false);
                }
              }

              Widget buildTypeChip(String value, String label) {
                final bool selected = selectedType == value;
                return ChoiceChip( // Gebruik ChoiceChip voor selecteerbare chips
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

                    if (isAdmin) ...[
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(
                          Icons.admin_panel_settings_outlined,
                        ),
                        title: const Text('Bekijk alle feedback'),
                        onTap: () {
                          Navigator.of(ctx).pop(); // Sluit de sheet
                          Navigator.of(outerContext).push(
                            MaterialPageRoute(
                              builder: (_) => const AllFeedbackView(), // Navigeer met outerContext
                            ),
                          );
                        },
                        tileColor: Theme.of(
                          ctx,
                        ).colorScheme.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const Divider(height: 24),
                    ],

                    const SizedBox(height: 16),

                    /// ⭐ Rating
                    Row(
                      children: List.generate(5, (i) { // 5 sterren
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
                            validator: (v) => (v == null || v.trim().isEmpty) //  Validator voor leeg bericht
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

class AllFeedbackView extends StatelessWidget {
  const AllFeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alle Feedback')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { // Wacht op data
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) { // Geen feedback
            return const Center(child: Text('Geen feedback gevonden.'));
          }
          if (snapshot.hasError) { // Fout bij ophalen
            return const Center(child: Text('Er is een fout opgetreden.'));
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = data['uid'] as String?;
              final platform = data['platform'] as String?;

              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('dd-MM-yyyy HH:mm').format(timestamp.toDate())
                  : 'Onbekende datum';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['message'] ?? 'Geen bericht',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const Divider(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(label: Text(data['type'] ?? 'onbekend')), // Type feedback
                          if (data['rating'] != null && data['rating'] > 0) // Rating weergeven als die er is
                            Chip(
                              avatar: const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              label: Text('${data['rating']}/5'),
                            ),

                          if (platform != null) //  Platform weergeven als die er is
                            Chip(
                              avatar: const Icon(Icons.devices, size: 16),
                              label: Text(platform),
                            ),

                          if (uid != null) UserDetailChip(uid: uid), // Toon gebruikerschip als UID er is

                          if (data['email'] != null &&
                              (data['email'] as String).isNotEmpty)
                            Chip(
                              avatar: const Icon(
                                Icons.email_outlined,
                                size: 16,
                              ),
                              label: Text(data['email']),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingezonden op: $date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith( // Datum stijl
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                      if (uid != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'UID: $uid',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class UserDetailChip extends StatefulWidget {
  final String uid;
  const UserDetailChip({super.key, required this.uid});

  @override
  State<UserDetailChip> createState() => _UserDetailChipState();
}

class _UserDetailChipState extends State<UserDetailChip> {
  Future<DocumentSnapshot>? _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
  }

  Future<void> _launchEmail(String email) async { // E-mail app openen
    final String subject = 'Reactie op je feedback - fFinder';
    final String body = 'Hoi $email,\n\n\nGroetjes,\nHet fFinder team';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kon de mail-app niet openen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Chip(label: Text('Laden...'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink(); // Verberg als gebruiker niet gevonden is
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final email = userData['email'] as String?;

        if (email == null) return const SizedBox.shrink();

        return ActionChip(
          avatar: const Icon(Icons.person_outline, size: 16),
          label: Text(email),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]
              : Colors.blue[100],
          onPressed: () => _launchEmail(email),
        );
      },
    );
  }
}
