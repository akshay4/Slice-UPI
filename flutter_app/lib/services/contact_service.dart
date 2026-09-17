import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:permission_handler/permission_handler.dart';
import '../models/contact.dart';

class ContactService {
  ContactService._();
  static final ContactService instance = ContactService._();

  bool _permissionGranted = false;
  bool get hasPermission => _permissionGranted;

  List<Contact> _deviceContacts = [];
  List<Contact> get contacts => _deviceContacts;

  /// Request contacts permission and fetch real phone contacts
  Future<bool> requestAndLoadContacts() async {
    try {
      final status = await Permission.contacts.status;
      if (status.isGranted) {
        _permissionGranted = true;
        await _fetchContacts();
        return true;
      }

      final result = await Permission.contacts.request();
      if (result.isGranted) {
        _permissionGranted = true;
        await _fetchContacts();
        return true;
      } else {
        _permissionGranted = false;
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting contacts: $e');
      _permissionGranted = false;
      return false;
    }
  }

  Future<void> _fetchContacts() async {
    try {
      final rawContacts = await fc.FlutterContacts.getAll(
        properties: {fc.ContactProperty.name, fc.ContactProperty.phone},
      );

      final List<Contact> loaded = [];
      for (final c in rawContacts) {
        final name = (c.displayName ?? '').trim();
        if (name.isEmpty) continue;

        String phone = '';
        if (c.phones.isNotEmpty) {
          phone = c.phones.first.number.replaceAll(RegExp(r'[^\d+]'), '');
        }

        // Standardize clean UPI VPA from phone number or name
        String vpa;
        if (phone.isNotEmpty) {
          final cleanDigits = phone.replaceAll('+', '');
          final last10 = cleanDigits.length >= 10
              ? cleanDigits.substring(cleanDigits.length - 10)
              : cleanDigits;
          vpa = '$last10@upi';
        } else {
          final safeName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          vpa = '$safeName@sliceupi';
        }

        // Generate initials
        final parts = name.split(RegExp(r'\s+'));
        String initials = '';
        if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
          initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
          initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
        }

        final colors = [
          0xFF0B57D0,
          0xFF006241,
          0xFF7C3AED,
          0xFFE11D48,
          0xFF0284C7,
          0xFFD97706,
        ];
        final avatarColor = colors[name.hashCode.abs() % colors.length];

        loaded.add(
          Contact(
            id: c.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            vpa: vpa,
            initials: initials,
            category: phone.isNotEmpty ? 'Phone Contact' : 'Device Contact',
            avatarColor: avatarColor,
            phone: phone.isNotEmpty ? phone : null,
          ),
        );
      }

      _deviceContacts = loaded;
      debugPrint('Loaded ${_deviceContacts.length} device contacts');
    } catch (e) {
      debugPrint('Failed to fetch device contacts: $e');
    }
  }

  /// Open app settings if user permanently denied permission
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
