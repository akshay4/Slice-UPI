import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';

class ContactPickerSheet extends StatefulWidget {
  const ContactPickerSheet({super.key});

  static Future<Contact?> show(BuildContext context) {
    return showModalBottomSheet<Contact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ContactPickerSheet(),
    );
  }

  @override
  State<ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<ContactPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filtered = [];
  bool _isLoading = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkAndLoadContacts();
  }

  Future<void> _checkAndLoadContacts() async {
    setState(() => _isLoading = true);
    final granted = await ContactService.instance.requestAndLoadContacts();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _permissionDenied = !granted;
        _filtered = ContactService.instance.contacts;
      });
    }
  }

  void _filterContacts(String query) {
    final all = ContactService.instance.contacts;
    if (query.trim().isEmpty) {
      setState(() => _filtered = all);
    } else {
      final q = query.toLowerCase();
      setState(() {
        _filtered = all.where((c) {
          final matchesName = c.name.toLowerCase().contains(q);
          final matchesPhone = c.phone?.toLowerCase().contains(q) ?? false;
          final matchesVpa = c.vpa.toLowerCase().contains(q);
          return matchesName || matchesPhone || matchesVpa;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.contacts_rounded, color: Color(0xFF0F62FE), size: 24),
                const SizedBox(width: 10),
                Text(
                  'Select Contact',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF16191D),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Search box
          if (!_permissionDenied)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filterContacts,
                decoration: InputDecoration(
                  hintText: 'Search real contacts or phone...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filterContacts('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF4F6FB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          // Content
          Expanded(
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_permissionDenied) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F62FE).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 48,
                color: Color(0xFF0F62FE),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Contacts Access Required',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Allow SlicePay to access your real phone contacts so you can split UPI payments with your friends and local stores.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkAndLoadContacts,
              icon: const Icon(Icons.security_rounded),
              label: const Text('Grant Contacts Permission'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F62FE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => ContactService.instance.openSettings(),
              child: const Text('Open App Settings'),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'No contacts found on device.'
              : 'No matching contacts for "${_searchController.text}".',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filtered.length,
      separatorBuilder: (_, _) => Divider(color: Colors.grey.shade100, height: 1),
      itemBuilder: (context, index) {
        final contact = _filtered[index];
        final color = Color(contact.avatarColor);

        return Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              foregroundColor: color,
              child: Text(
                contact.initials,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            subtitle: Text(
              contact.phone ?? contact.vpa,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            onTap: () {
              Navigator.of(context).pop(contact);
            },
          ),
        );
      },
    );
  }
}
