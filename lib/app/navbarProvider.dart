import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/Auth/auth_repository.dart';
import 'package:happy_tails/UserManage/screens/profile_page.dart';
import 'package:happy_tails/UserManage/screens/settings_page.dart';
import 'package:happy_tails/chat/chat_provider.dart';
import 'package:happy_tails/chat/clientList.dart';
import 'package:happy_tails/chat/petSitterList.dart';
import 'package:happy_tails/homePagePetSitter.dart';
import 'package:happy_tails/screens/ricerca/risultatiricerca_pagina.dart';

class PageManager extends StateNotifier<List<Widget>> {
  PageManager() : super([]){
  _initializePages();
  }

  // Metodo per inizializzare le pagine al momento del riavvio
  Future<void> _initializePages() async {
    final session = supabase.auth.currentUser;

    if (session != null) {
      final isPetSitter = await _checkIfPetSitter();
      state = isPetSitter
          ? [HomePagePetSitter(), RisultatiCercaPage(), ClientListPage(), UserProfilePage()]
          : [UserProfilePage(), RisultatiCercaPage(), UserListPage(), SettingsPage()];
    } else {
      state = [LoginPage(), RisultatiCercaPage()];
    }
  }


  Future<void> updatePages() async {
    final session = supabase.auth.currentUser;
    if (session != null) {
      final isPetSitter = await _checkIfPetSitter();
      state = isPetSitter
          ? [HomePagePetSitter(), RisultatiCercaPage(), ClientListPage(), UserProfilePage()]
          : [UserProfilePage(), RisultatiCercaPage(), UserListPage(), SettingsPage()];    
    } else {
      state = [LoginPage(), RisultatiCercaPage()];
    }
  }


  Future<bool> _checkIfPetSitter() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('email', supabase.auth.currentUser!.email as Object)
        .maybeSingle();

    return response?['isPetSitter'] ?? false;
  }
}