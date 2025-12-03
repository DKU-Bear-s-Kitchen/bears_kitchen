import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 데이터 저장소
  List<Map<String, dynamic>> _stores = []; // 식당 목록
  List<Map<String, dynamic>> _menus = [];  // 전체 메뉴 목록

  // 🔥 필터링 상태 변수
  List<String> _selectedStoreIds = []; // 선택된 식당 ID들
  RangeValues _priceRange = const RangeValues(0, 20000); // 가격 범위
  double _minRating = 0.0; // 최소 별점
  String _sortOption = '기본순'; // 정렬 옵션

  // 🔥 검색어 변수
  String _searchText = '';

  // 로딩 및 스트림 관리
  bool _isLoading = true;
  StreamSubscription? _storeSubscription;
  StreamSubscription? _menuSubscription;

  // Getter (외부에서 접근용)
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get allStores => _stores;
  List<String> get selectedStoreIds => _selectedStoreIds;
  RangeValues get priceRange => _priceRange;
  double get minRating => _minRating;
  String get sortOption => _sortOption;

  final TextEditingController searchController = TextEditingController();

  // 탭 상태
  int _bottomNavIndex = 1;
  String _selectedTab = '전체';

  int get bottomNavIndex => _bottomNavIndex;
  String get selectedTab => _selectedTab;

  // 생성자: 컨트롤러 생성 시 데이터 구독 시작
  HomeController() {
    startListening();
  }

  @override
  void dispose() {
    _storeSubscription?.cancel();
    _menuSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // 🔥 Firestore 데이터 실시간 구독 (get 대신 snapshots 사용)
  void startListening() {
    _isLoading = true;
    notifyListeners();

    // 1. 식당 목록 구독 (식당 전체 별점 사용)
    _storeSubscription = _firestore.collection('stores').snapshots().listen((snapshot) {
      _stores = snapshot.docs.map((doc) {
        final data = doc.data();

        final double avgRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

        return {
          'id': doc.id,
          'name': data['name'] ?? '이름 없음',
          'rating': '${avgRating.toStringAsFixed(1)} ($reviewCount)', // 화면 표시용
          'ratingDouble': avgRating, // 필터링용 숫자
          'reviewCount': reviewCount, // 정렬용 숫자
        };
      }).toList();
      notifyListeners();
    });

    // 2. 메뉴 목록 구독 (메뉴 고유 별점 사용)
    _menuSubscription = _firestore.collectionGroup('menus').snapshots().listen((snapshot) {
      _menus = snapshot.docs.map((doc) {
        final data = doc.data();
        final storeId = doc.reference.parent.parent!.id;

        // 가격 문자열에서 숫자만 추출
        int priceInt = 0;
        if (data['price'] != null) {
          String p = data['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
          priceInt = int.tryParse(p) ?? 0;
        }

        // 🔥 [중요] 메뉴 문서에 있는 별점과 리뷰 수를 그대로 사용!
        final double avgRating = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
        final int reviewCount = (data['reviewCount'] as num?)?.toInt() ?? 0;

        return {
          'id': doc.id,
          'storeId': storeId,
          'name': data['name'] ?? '메뉴명 없음',
          'priceStr': "${data['price']}원", // 화면 표시용
          'priceInt': priceInt,            // 필터링용 숫자
          'rating': '${avgRating.toStringAsFixed(1)} ($reviewCount)', // 메뉴 자체 별점
          'ratingDouble': avgRating,       // 정렬용
          'reviewCount': reviewCount,      // 정렬용
          'tags': (priceInt > 7000) ? 'popular' : 'new',
        };
      }).toList();

      _isLoading = false;
      notifyListeners();
    });
  }

  /// 🕵️‍♂️ 상세 필터가 작동 중인지 확인
  bool get _isDetailedFilterActive {
    return _priceRange.start > 0 || _priceRange.end < 20000 ||
           _minRating > 0.0 ||
           _sortOption != '기본순';
  }

  /// 🔥 [화면 결정 로직] 식당 목록을 보여줄까? 메뉴 목록을 보여줄까?
  bool get isShowingStores {
    // 1. 검색 중이면 -> 메뉴 리스트
    if (_searchText.isNotEmpty) return false;

    // 2. 탭이 '전체'가 아니면 -> 메뉴 리스트
    if (_selectedTab != '전체') return false;

    // 3. 상세 필터(가격/별점/정렬)를 건드렸으면 -> 메뉴 리스트
    if (_isDetailedFilterActive) return false;

    // 4. 그 외(기본 상태 or 식당만 필터링함) -> 식당 리스트 유지!
    return true;
  }

  /// 📋 화면에 보여줄 최종 리스트 반환
  List<Map<String, dynamic>> get displayedList {
    if (_isLoading) return [];

    // [CASE A] 식당 목록 모드
    if (isShowingStores) {
      if (_selectedStoreIds.isNotEmpty) {
        return _stores.where((store) => _selectedStoreIds.contains(store['id'])).toList();
      }
      return _stores;
    }

    // [CASE B] 메뉴 목록 모드
    List<Map<String, dynamic>> result = List.from(_menus);

    // 1. 검색어 필터
    if (_searchText.isNotEmpty) {
      result = result.where((menu) =>
        menu['name'].toString().toLowerCase().contains(_searchText.toLowerCase())
      ).toList();
    }

    // 2. 상단 탭 필터
    if (_selectedTab == '새 메뉴') {
      result = result.where((menu) => menu['tags'].toString().contains('new')).toList();
    } else if (_selectedTab == '인기 메뉴') {
      result = result.where((menu) => menu['tags'].toString().contains('popular')).toList();
    }

    // 3. 식당 필터
    if (_selectedStoreIds.isNotEmpty) {
      result = result.where((menu) => _selectedStoreIds.contains(menu['storeId'])).toList();
    }

    // 4. 가격 범위 필터
    result = result.where((menu) {
      final price = menu['priceInt'] as int;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // 5. 별점 필터 (메뉴 별점 기준)
    if (_minRating > 0) {
      result = result.where((menu) => (menu['ratingDouble'] as double) >= _minRating).toList();
    }

    // 6. 정렬 로직 (메뉴 데이터 기준)
    if (_sortOption == '가격 낮은순') {
      result.sort((a, b) => (a['priceInt'] as int).compareTo(b['priceInt'] as int));
    } else if (_sortOption == '가격 높은순') {
      result.sort((a, b) => (b['priceInt'] as int).compareTo(a['priceInt'] as int));
    } else if (_sortOption == '별점 높은순') {
      result.sort((a, b) => (b['ratingDouble'] as double).compareTo(a['ratingDouble'] as double));
    } else if (_sortOption == '리뷰 많은순') {
      result.sort((a, b) => (b['reviewCount'] as int).compareTo(a['reviewCount'] as int));
    }

    return result;
  }

  // --- 필터 값 설정 함수들 ---
  void setStoreFilter(List<String> storeIds) {
    _selectedStoreIds = storeIds;
    notifyListeners();
  }

  void setPriceFilter(RangeValues range) {
    _priceRange = range;
    notifyListeners();
  }

  void setRatingFilter(double rating) {
    _minRating = rating;
    notifyListeners();
  }

  void setSortOption(String option) {
    _sortOption = option;
    notifyListeners();
  }

  void resetFilters() {
    _selectedStoreIds = [];
    _priceRange = const RangeValues(0, 20000);
    _minRating = 0.0;
    _sortOption = '기본순';
    notifyListeners();
  }

  // --- 기본 UI 조작 함수들 ---
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