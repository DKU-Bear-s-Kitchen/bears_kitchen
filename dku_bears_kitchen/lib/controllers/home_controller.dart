import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController with ChangeNotifier {
  // 🔥 Firestore 인스턴스 가져오기
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔥 진짜 데이터를 담을 리스트 (처음엔 비어있음)
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _menus = [];

  // 데이터 로딩 중인지 확인하는 변수
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get allStores => _stores;
  List<Map<String, dynamic>> get allMenus => _menus;

  int _bottomNavIndex = 1;
  String _selectedTab = '전체';
  String _searchText = '';

  final TextEditingController searchController = TextEditingController();

  int get bottomNavIndex => _bottomNavIndex;
  String get selectedTab => _selectedTab;

  // 생성자: 컨트롤러가 만들어질 때 데이터 불러오기 시작
  HomeController() {
    fetchData();
  }

  /// -------------------------------------------------------
  /// 🔥 [핵심] Firestore에서 식당과 메뉴 데이터 가져오기
  /// -------------------------------------------------------
  Future<void> fetchData() async {
    try {
      _isLoading = true;
      notifyListeners(); // "로딩 시작했다"고 알림

      // 1. 식당 목록 가져오기 (stores 컬렉션)
      final storeSnapshot = await _firestore.collection('stores').get();
      _stores = storeSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '이름 없음',
          // Firestore에 없는 필드는 임시로 채워줌 (UI 에러 방지)
          'tags': 'all',
          'rating': '4.0 (New)',
        };
      }).toList();

      // 2. 모든 메뉴 가져오기 (Collection Group Query 사용)
      // 'menus'라는 이름을 가진 모든 하위 컬렉션을 다 뒤져서 가져옴
      final menuSnapshot = await _firestore.collectionGroup('menus').get();
      _menus = menuSnapshot.docs.map((doc) {
        final data = doc.data();
        final storeId = doc.reference.parent.parent!.id;
        return {
          'id': doc.id,
          'storeId': storeId,
          'name': data['name'] ?? '메뉴명 없음',
          'price': "${data['price']}원", // 숫자를 문자열로 변환
          // 태그가 DB에 없으면 가격이나 이름 기반으로 임시 태그 생성 (필터링 테스트용)
          'tags': data['price'] > 7000 ? 'all, popular' : 'all, new',
          'rating': '4.5',
        };
      }).toList();

      print("✅ 데이터 로드 완료: 식당 ${_stores.length}개, 메뉴 ${_menus.length}개");

    } catch (e) {
      print("❌ 데이터 가져오기 실패: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); // "로딩 끝났다! 화면 갱신해!"라고 알림
    }
  }

  /// -------------------------------------------------------
  /// 👇 아래 로직은 기존과 거의 동일 (필터링 로직)
  /// -------------------------------------------------------

  bool get isShowingStores {
    if (_searchText.isNotEmpty) return false;
    if (_selectedTab == '새 메뉴') return false;
    if (_selectedTab == '인기 메뉴') return false;
    return true;
  }

  List<Map<String, dynamic>> get displayedList {
    // 로딩 중이면 빈 리스트 반환 (UI에서 로딩바 처리 필요)
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