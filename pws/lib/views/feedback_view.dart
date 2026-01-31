import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

class FeedbackButton extends StatelessWidget {
  final double bottom; // afstand vanaf de onderkant
  final double right; // afstand vanaf de rechterkant

  const FeedbackButton({Key? key, this.bottom = 120, this.right = 16})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // In dark mode, lighter teal is more visible. In light mode, default teal is fine.
    final baseColor = isDarkMode ? Colors.tealAccent.shade700 : Colors.teal;

    return FloatingActionButton(
      heroTag: 'feedback_btn',
      backgroundColor: baseColor.withOpacity(0.8),
      mini: true,
      onPressed: () => _openFeedbackSheet(context),
      child: Icon(Icons.feedback, color: Colors.white),
    );
  }

  void _openRapportFeedbackSheet(BuildContext context) async {
    final outerContext = context;
    final formKey = GlobalKey<FormState>();
    final Map<String, List<String>> categories = {
      // feedback categorieën en items
      'functionality': [
        'features',
        'functionality_item',
        'usability',
        'clarity',
        'accuracy',
        'navigation',
      ],
      'performance': ['speed', 'loading_times', 'stability'],
      'interface_design': [
        'layout',
        'colors_theme',
        'icons_design',
        'readability',
      ],
      'communication': ['errors', 'explanation'],
      'app_parts': ['dashboard', 'login', 'weight', 'statistics', 'calendar'],
      'other': ['general_satisfaction'],
    };
    final Map<String, int> ratings = {
      // initiële ratings
      for (var group in categories.values)
        for (var item in group) item: 0,
    };

    final Map<String, TextEditingController> comments = {
      // commentaar controllers
      for (var group in categories.values)
        for (var item in group) item: TextEditingController(),
    };

    bool isSending = false;

    showModalBottomSheet<void>(
      context: outerContext,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Theme.of(outerContext).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final isDarkMode = Theme.of(ctx).brightness == Brightness.dark;
        final Color textColor = isDarkMode ? Colors.white : Colors.black;
        final Color hintColor = isDarkMode
            ? Colors.grey.shade400
            : Colors.grey.shade700;
        final sysBottomPadding = MediaQuery.of(ctx).padding.bottom;

        final loc = AppLocalizations.of(ctx)!;

        Future<void> send() async {
          // verzend feedback
          if (!formKey.currentState!.validate()) return;
          isSending = true;
          try {
            final user = FirebaseAuth.instance.currentUser;
            await FirebaseFirestore.instance.collection('rapport_feedback').add(
              {
                'uid': user?.uid,
                'timestamp': FieldValue.serverTimestamp(),
                'ratings': ratings,
                'comments': {
                  for (var k in comments.keys) k: comments[k]!.text.trim(),
                },
                'platform': Theme.of(outerContext).platform.name,
              },
            );
            if (ctx.mounted) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(
                outerContext,
              ).showSnackBar(SnackBar(content: Text(loc.reportThanks)));
            }
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(outerContext).showSnackBar(
                SnackBar(content: Text('${loc.errorSending}: $e')),
              );
            }
          } finally {
            isSending = false;
          }
        }

        Widget buildRatingRow(
          // bouw rij voor beoordeling
          String keyLabel,
          String displayLabel,
          void Function(void Function()) setState, // to update state
        ) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayLabel,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              Row(
                children: List.generate(5, (i) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        ratings[keyLabel] = i + 1;
                      });
                    },
                    icon: Icon(
                      Icons.star,
                      color: i < (ratings[keyLabel] ?? 0)
                          ? Colors.amber
                          : (isDarkMode ? Colors.grey[600] : Colors.grey[500]),
                    ),
                  );
                }),
              ),
              TextFormField(
                controller: comments[keyLabel],
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: loc.commentOptional.replaceAll(
                    '{label}',
                    displayLabel,
                  ),
                  hintStyle: TextStyle(color: hintColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
            ],
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (sheetCtx, scrollController) {
            return StatefulBuilder(
              builder: (ctx, setState) => Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom:
                      MediaQuery.of(ctx).viewInsets.bottom +
                      sysBottomPadding +
                      20,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Text(
                          loc.reportTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...categories.entries.map((entry) {
                          // voor elke categorie
                          String catLabel; // categorielabel
                          List<String> itemDisplayLabels = [];
                          switch (entry.key) {
                            case 'functionality':
                              catLabel = loc.categoryFunctionality;
                              itemDisplayLabels = [
                                loc.itemFeatures,
                                loc.itemFunctionality,
                                loc.itemUsability,
                                loc.itemClarity,
                                loc.itemAccuracy,
                                loc.itemNavigation,
                              ];
                              break;
                            case 'performance':
                              catLabel = loc.categoryPerformance;
                              itemDisplayLabels = [
                                loc.itemSpeed,
                                loc.itemLoadingTimes,
                                loc.itemStability,
                              ];
                              break;
                            case 'interface_design':
                              catLabel = loc.categoryInterfaceDesign;
                              itemDisplayLabels = [
                                loc.itemLayout,
                                loc.itemColorsTheme,
                                loc.itemIconsDesign,
                                loc.itemReadability,
                              ];
                              break;
                            case 'communication':
                              catLabel = loc.categoryCommunication;
                              itemDisplayLabels = [
                                loc.itemErrors,
                                loc.itemExplanation,
                              ];
                              break;
                            case 'app_parts':
                              catLabel = loc.categoryAppParts;
                              itemDisplayLabels = [
                                loc.itemDashboard,
                                loc.itemLogin,
                                loc.itemWeight,
                                loc.itemStatistics,
                                loc.itemCalendar,
                              ];
                              break;
                            default:
                              catLabel = loc.categoryOther;
                              itemDisplayLabels = [loc.itemGeneralSatisfaction];
                          }

                          return ExpansionTile(
                            // uitklapbare categorie
                            title: Text(
                              catLabel, // categorienaam
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            textColor: textColor,
                            collapsedTextColor: textColor,
                            iconColor: textColor,
                            collapsedIconColor: textColor,
                            children: List.generate(entry.value.length, (i) {
                              // voor elk item in de categorie
                              final internalKey = entry.value[i];
                              final displayLabel = itemDisplayLabels.length > i
                                  ? itemDisplayLabels[i]
                                  : internalKey;
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: 12,
                                ),
                                child: buildRatingRow(
                                  internalKey,
                                  displayLabel,
                                  setState,
                                ),
                              );
                            }),
                          );
                        }).toList(), // sluit map
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                loc.cancel,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: isSending
                                  ? null
                                  : () {
                                      setState(() => isSending = true);
                                      send().whenComplete(
                                        // na verzenden
                                        () => setState(() => isSending = false),
                                      );
                                    },
                              child: isSending
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: textColor,
                                      ),
                                    )
                                  : Text(loc.send),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openFeedbackSheet(BuildContext context) async { // open feedback formulier
    final outerContext = context;
    final formKey = GlobalKey<FormState>();
    final messageController = TextEditingController();
    final emailController = TextEditingController();

    int rating = 0;
    bool isSending = false;
    String selectedType = 'bug';
    String languageReported = Localizations.localeOf(context).languageCode;

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
        debugPrint("Kon admin status niet controleren: $e");
      }
    }

    showModalBottomSheet<void>(
      context: outerContext,
      isScrollControlled: true,
      backgroundColor: Theme.of(outerContext).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet( // Sleepbaar modaal blad
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false, 
          builder: (sheetCtx, scrollController) { // bouw inhoud
            final isDarkMode = Theme.of(sheetCtx).brightness == Brightness.dark;
            final sysBottomPadding = MediaQuery.of(sheetCtx).padding.bottom;
            final loc = AppLocalizations.of(sheetCtx)!;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom:
                    MediaQuery.of(sheetCtx).viewInsets.bottom +
                    sysBottomPadding +
                    20,
              ),
              child: StatefulBuilder(
                builder: (innerCtx, setState) { // voor state updates
                  Future<void> send() async {
                    if (!formKey.currentState!.validate()) return;

                    setState(() => isSending = true);

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      final appLanguage = Localizations.localeOf(
                        outerContext,
                      ).languageCode;

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
                            'languageReported': selectedType == 'language'
                                ? languageReported
                                : null,
                            'appLanguage': appLanguage,
                            'timestamp': FieldValue.serverTimestamp(),
                            'platform': Theme.of(outerContext).platform.name,
                          });

                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          SnackBar(content: Text(loc.thanksFeedback)),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          SnackBar(content: Text('${loc.errorSending}: $e')),
                        );
                      }
                    } finally {
                      if (ctx.mounted) setState(() => isSending = false);
                    }
                  }

                  Widget buildTypeChip(String value, String label) { // bouw keuze chip
                    final bool selected = selectedType == value;
                    return ChoiceChip(
                      label: Text(
                        label,
                        style: TextStyle(
                          color: selected
                              ? (isDarkMode ? Colors.black : Colors.white)
                              : (isDarkMode ? Colors.grey[300] : Colors.black),
                        ),
                      ),
                      selected: selected,
                      selectedColor: isDarkMode ? Colors.tealAccent : Colors.teal,
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      onSelected: (_) { // update selectie
                        setState(() => selectedType = value);
                      },
                    );
                  }

                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Text(
                          loc.feedbackTitle,
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
                            title: Text(loc.viewAllFeedback),
                            onTap: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(outerContext).push(
                                MaterialPageRoute(
                                  builder: (_) => const AllFeedbackView(),
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
                          ListTile(
                            leading: const Icon(
                              Icons.assignment_turned_in_outlined,
                            ),
                            title: Text(loc.viewAllRapportFeedback),
                            onTap: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(outerContext).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AllRapportFeedbackView(),
                                ),
                              );
                            },
                            tileColor: Theme.of(
                              ctx, // gebruik context van sheet
                            ).colorScheme.primary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const Divider(height: 24),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.assignment_outlined),
                          label: Text(loc.openRapportButton),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _openRapportFeedbackSheet(context),
                        ),
                        const Divider(height: 16),
                        const SizedBox(height: 16),
                        Text(
                          loc.feedbackIntro,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                        Row(
                          children: List.generate(5, (i) {
                            return IconButton(
                              onPressed: () => setState(() => rating = i + 1), // update rating
                              icon: Icon(
                                Icons.star,
                                color: i < rating
                                    ? Colors.amber
                                    : Colors.grey[500],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            buildTypeChip('bug', loc.choiceBug),
                            buildTypeChip('feature', loc.choiceFeature),
                            buildTypeChip('language', loc.choiceLanguage),
                            buildTypeChip('layout', loc.choiceLayout),
                            buildTypeChip('other', loc.choiceOther),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (selectedType == 'language') ...[
                          const SizedBox(height: 12),
                          Text(
                            loc.languageSectionInstruction,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: languageReported,
                            dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                            style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'nl',
                                child: Text('Nederlands (nl)'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English (en)'),
                              ),
                              DropdownMenuItem(
                                value: 'fr',
                                child: Text('Français (fr)'),
                              ),
                              DropdownMenuItem(
                                value: 'de',
                                child: Text('Deutsch (de)'),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              if (v != null) languageReported = v;
                            }),
                            decoration: InputDecoration(
                              labelText: loc.dropdownLabelLanguage,
                              labelStyle: TextStyle(
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
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
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: loc.messageHint,
                                  hintStyle: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? loc.enterMessage
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: loc.emailHintOptional,
                                  hintStyle: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: isDarkMode ? Colors.grey[600]! : Colors.grey,
                                    ),
                                  ),
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
                              child: Text(loc.cancel),
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
                                  : Text(loc.send),
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
      },
    );
  }
}

class AllFeedbackView extends StatelessWidget { // bekijk alle feedback (admin)
  const AllFeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.allFeedbackTitle)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(loc.noFeedbackFound));
          }
          if (snapshot.hasError) {
            return Center(child: Text(loc.errorOccurred));
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = data['uid'] as String?;
              final platform = data['platform'] as String?;
              final appLanguage = data['appLanguage'] as String?;
              final languageReported = data['languageReported'] as String?;

              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('dd-MM-yyyy HH:mm').format(timestamp.toDate())
                  : loc.unknownDate;

              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['message'] ?? loc.noMessage,
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
                          Chip(label: Text(data['type'] ?? loc.unknownType)),
                          if (data['rating'] != null && data['rating'] > 0)
                            Chip(
                              avatar: const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              label: Text('${data['rating']}/5'),
                            ),
                          if (platform != null)
                            Chip(
                              avatar: const Icon(Icons.devices, size: 16),
                              label: Text(platform),
                            ),
                          if (appLanguage != null && appLanguage.isNotEmpty)
                            Chip(
                              avatar: const Icon(Icons.language, size: 16),
                              label: Text(
                                '${loc.appLanguagePrefix}$appLanguage',
                              ),
                            ),
                          if (languageReported != null &&
                              languageReported.isNotEmpty)
                            Chip(
                              avatar: const Icon(Icons.translate, size: 16),
                              label: Text(
                                '${loc.reportedLanguagePrefix}$languageReported',
                              ),
                            ),
                          if (uid != null) UserDetailChip(uid: uid),
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
                        '${loc.submittedOnPrefix}$date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                      if (uid != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${loc.uidLabelPrefix}$uid',
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

class _UserDetailChipState extends State<UserDetailChip> { // haal user details op
  Future<DocumentSnapshot>? _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
  }

  Future<void> _launchEmail(String email) async { // open email app
    final loc = AppLocalizations.of(context)!;
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
          SnackBar(content: Text('${loc.couldNotOpenMailAppPrefix}$e')),
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
          return Chip(label: Text(AppLocalizations.of(context)!.loading));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
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

class AllRapportFeedbackView extends StatelessWidget { // bekijk alle rapport feedback (admin)
  const AllRapportFeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.allRapportFeedbackTitle)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rapport_feedback')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(loc.noRapportFeedbackFound));
          }
          if (snapshot.hasError) {
            return Center(child: Text(loc.errorOccurred));
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
                  : loc.unknownDate;

              final ratings = data['ratings'] as Map<String, dynamic>? ?? {};
              final comments = data['comments'] as Map<String, dynamic>? ?? {};

              return Card(
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.rapportFeedbackTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...ratings.entries.map((entry) {
                        final label = entry.key;
                        final value = entry.value;
                        final comment = comments[label] ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    size: 18,
                                    color: i < (value ?? 0)
                                        ? Colors.amber
                                        : Colors.grey[400],
                                  ),
                                ),
                              ),
                              if ((comment as String).isNotEmpty)
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      comment,
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[300]
                                            : Colors.grey[800],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      const Divider(),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (platform != null)
                            Chip(
                              avatar: const Icon(Icons.devices, size: 16),
                              label: Text(platform),
                            ),
                          if (uid != null) UserDetailChip(uid: uid),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${loc.submittedOnPrefix}$date',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                      if (uid != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${loc.uidLabelPrefix}$uid',
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
