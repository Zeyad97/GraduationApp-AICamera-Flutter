import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/database_service.dart';

class ContactProvider extends ChangeNotifier {
  List<ContactModel> _contacts = [];
  bool _isLoading = false;

  List<ContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;
  
  List<ContactModel> get emergencyContacts =>
      _contacts.where((c) => c.isEmergencyContact).toList();

  Future<void> loadContacts(String userId) async {
    _isLoading = true;
    notifyListeners();

    _contacts = await DatabaseService.instance.getContactsByUserId(userId);
    _contacts.sort((a, b) => b.isEmergencyContact ? 1 : -1);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addContact(ContactModel contact) async {
    await DatabaseService.instance.insertContact(contact);
    await loadContacts(contact.userId);
  }

  Future<void> updateContact(ContactModel contact) async {
    await DatabaseService.instance.updateContact(contact);
    await loadContacts(contact.userId);
  }

  Future<void> deleteContact(String contactId, String userId) async {
    await DatabaseService.instance.deleteContact(contactId);
    await loadContacts(userId);
  }

  Future<void> toggleEmergencyContact(String contactId, String userId) async {
    final contact = _contacts.firstWhere((c) => c.id == contactId);
    final updatedContact = contact.copyWith(
      isEmergencyContact: !contact.isEmergencyContact,
    );
    await updateContact(updatedContact);
  }
}
