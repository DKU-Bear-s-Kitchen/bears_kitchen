import 'dart:async'; // StreamSubscription을 위해 필요
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _menus = [];

  bool _isLoading = true;

  // 🔥 스트림을 관리하기 위한 변수 (메모리 누수 방지)
  StreamSubscription? _storeSubscription;
  StreamSubscription? _menuSubscription;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get allStores => _stores;
  List<Map<String, dynamic>> get allMenus => _menus;

  int _bottomNavIndex = 1;
  String _selectedTab = '전체';
  String _searchText = '';

  final TextEditingController searchController = TextEditingController();

  int get bottomNavIndex => _bottomNavIndex;
  String get selectedTab => _selectedTab;

  HomeController() {
    startListening();
  }

  // 컨트롤러가 사라질 때 스트림도 끊어줘야 함 (안전장치)
  @override
  void dispose() {
    _storeSubscription?.cancel();
    _menuSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  /// -------------------------------------------------------
  /// 🔥 [핵심 변경] get() 대신 snapshots()을 사용해 실시간 감시
  /// -------------------------------------------------------
  void startListening() {
    _isLoading = true;
    notifyListeners();

    // 1. 식당 목록 실시간 구독 (Stores)
    _storeSubscription = _firestore.collection('stores').snapshots().listen((snapshot) {
      _stores = snapshot.docs.map((doc) {
        final data = doc.data();

        // 데이터베이스가 변경되면 이 부분이 자동으로 실행되어 점수를 갱신함
        final double avgRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

        return {
          'id': doc.id,
          'name': data['name'] ?? '이름 없음',
          'tags': 'all',
          'rating': '${avgRating.toStringAsFixed(1)} ($reviewCount)',
        };
      }).toList();

      _isLoading = false;
      notifyListeners(); // 화면 갱신 알림
    });

    // 2. 메뉴 목록 실시간 구독 (Menus)
    _menuSubscription = _firestore.collectionGroup('menus').snapshots().listen((snapshot) {
      _menus = snapshot.docs.map((doc) {
        final data = doc.data();
        final storeId = doc.reference.parent.parent!.id;

        // (참고: 아까 메뉴 별점 업데이트 기능은 뺐으므로, 메뉴 쪽 점수는 0.0으로 나올 수 있음)
        final double avgRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

        return {
          'id': doc.id,
          'storeId': storeId,
          'name': data['name'] ?? '메뉴명 없음',
          'price': "${data['price']}원",
          'tags': (data['price'] ?? 0) > 7000 ? 'all, popular' : 'all, new',
          'rating': '${avgRating.toStringAsFixed(1)} ($reviewCount)',
        };
      }).toList();

      _isLoading = false;
      notifyListeners(); // 화면 갱신 알림
    });
  }

  /// -------------------------------------------------------
  /// 👇 필터링 로직 (기존 동일)
  /// -------------------------------------------------------

  bool get isShowingStores {
    if (_searchText.isNotEmpty) return false;
    if (_selectedTab == '새 메뉴') return false;
    if (_selectedTab == '인기 메뉴') return false;
    return true;
  }

  List<Map<String, dynamic>> get displayedList {
    if (_isLoading) return [];

    if (_searchText.isNotEmpty) {
      return _menus.where((menu) {
        final name = menu['name'].toString().toLowerCase();
        return name.contains(_searchText.toLowerCase());
      }).toList();
    } else if (_selectedTab == '새 메뉴') {
      return _menus.where((menu) => menu['tags'].toString().contains('new')).toList();
    } else if (_selectedTab == '인기 메뉴') {
      return _menus.where((menu) => menu['tags'].toString().contains('popular')).toList();
    } else {
      return _stores;
    }
  }

  void onBottomNavTap(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  void onTabSelected(String label) {
    _selectedTab = label;
    _searchText = '';
    searchController.clear();
    notifyListeners();
  }

  void onSearchChanged(String value) {
    _searchText = value;
    notifyListeners();
  }
}