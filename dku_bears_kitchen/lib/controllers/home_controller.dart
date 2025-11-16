import 'package:flutter/material.dart';

class HomeController with ChangeNotifier {
//식당 리스트(가짜 데이터)
  final List<Map<String, String>> allStores = [
    { 'id': 'store_01', 'name': '바비든든', 'tags': 'all', 'price': '', 'rating': '4.5 (120)' },
    { 'id': 'store_02', 'name': '경성카츠', 'tags': 'all', 'price': '', 'rating': '4.2 (89)' },
    { 'id': 'store_03', 'name': '폭풍분식', 'tags': 'all', 'price': '', 'rating': '4.2 (89)' },
  ];

  //메뉴 리스트(가짜 데이터)
  final List<Map<String, String>> allMenus = [
    { 'name': '우삼겹 덮밥', 'tags': 'all, 덮밥', 'price': '4,500원', 'rating': '4.5 (120)' },
    { 'name': '참치마요 덮밥', 'tags': 'all, 덮밥', 'price': '3,800원', 'rating': '4.2 (89)' },
    { 'name': '치킨 데리야끼 덮밥', 'tags': 'all, 덮밥', 'price': '4,200원', 'rating': '4.3 (95)' },
    { 'name': '사골 칼국수', 'tags': 'all, new', 'price': '5,000원', 'rating': '4.8 (30)' },
    { 'name': '육회 비빔밥', 'tags': 'all, new', 'price': '6,500원', 'rating': '4.9 (50)' },
    { 'name': '라면', 'tags': 'all, popular', 'price': '2,500원', 'rating': '4.1 (200)' },
    { 'name': '마라 쌀국수', 'tags': 'all, popular', 'price': '5,500원', 'rating': '4.7 (150)' },
    { 'name': '고구마 치즈 돈까스', 'tags': 'all, popular', 'price': '6,000원', 'rating': '4.6 (130)' },
  ];

  int _bottomNavIndex = 1;
  String _selectedTab = '전체';
  String _searchText = '';
  
  final TextEditingController searchController = TextEditingController();

  int get bottomNavIndex => _bottomNavIndex;
  String get selectedTab => _selectedTab;
  
  bool get isShowingStores {
    if (_searchText.isNotEmpty) return false;
    if (_selectedTab == '새 메뉴') return false;
    if (_selectedTab == '인기 메뉴') return false;
    return true;
  }
  
  List<Map<String, String>> get displayedList {
    if (_searchText.isNotEmpty) {
      return allMenus.where((menu) {
        return menu['name']!.toLowerCase().contains(_searchText.toLowerCase());
      }).toList();
    } else if (_selectedTab == '새 메뉴') {
      return allMenus.where((menu) => menu['tags']!.contains('new')).toList();
    } else if (_selectedTab == '인기 메뉴') {
      return allMenus.where((menu) => menu['tags']!.contains('popular')).toList();
    } else {
      return allStores;
    }
  }

  //하단 탭 누름
  void onBottomNavTap(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  //상단 탭 누름
  void onTabSelected(String label) {
    _selectedTab = label;
    _searchText = '';
    searchController.clear(); 
    notifyListeners();
  }
  
  //검색창에 글자 입력
  void onSearchChanged(String value) {
    _searchText = value;
    notifyListeners();
  }
}