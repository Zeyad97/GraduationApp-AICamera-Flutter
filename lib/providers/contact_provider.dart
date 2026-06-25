import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';

class ContactProvider extends ChangeNotifier {
  List<ContactModel> _contacts = [];
  bool _isLoading = false;

  List<ContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;
  
  List<ContactModel> get emergencyContacts =>
      _contacts.where((c) => c.isEmergencyContact).toList();

  // Initialize real-time listener for a user
  void initializeUser(String userId) {
    _setupContactsListener(userId);
  }

  // Setup real-time stream listener for contacts
  void _setupContactsListener(String userId) {
    try {
      // Note: FirestoreService doesn't have a contacts stream yet, but we'll load periodically
      loadContacts(userId);
    } catch (e) {
      print('Error setting up contacts listener: $e');
    }
  }

  Future<void> loadContacts(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load from Firestore
      _contacts = await FirestoreService.instance.getContactsByUserId(userId);
      _contacts.sort((a, b) => b.isEmergencyContact ? 1 : -1);
      
      // Cache in local database
      for (var contact in _contacts) {
        await DatabaseService.instance.insertContact(contact);
      }
    } catch (e) {
      print('Error loading contacts from Firestore: $e');
      // Fallback to local database
      _contacts = await DatabaseService.instance.getContactsByUserId(userId);
      _contacts.sort((a, b) => b.isEmergencyContact ? 1 : -1);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addContact(ContactModel contact) async {
    try {
      // Save to Firestore
      await FirestoreService.instance.saveContact(contact);
    } catch (e) {
      print('Error saving contact to Firestore: $e');
    }

    // Always save to local database
    await DatabaseService.instance.insertContact(contact);
    await loadContacts(contact.userId);
  }

  Future<void> updateContact(ContactModel contact) async {
    try {
      // Update in Firestore
      await FirestoreService.instance.updateContact(contact);
    } catch (e) {
      print('Error updating contact in Firestore: $e');
    }

    // Update local database
    await DatabaseService.instance.updateContact(contact);
    await loadContacts(contact.userId);
  }

  Future<void> deleteContact(String contactId, String userId) async {
    try {
      // Delete from Firestore
      await FirestoreService.instance.deleteContact(userId, contactId);
    } catch (e) {
      print('Error deleting contact from Firestore: $e');
    }

    // Delete from local database
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
