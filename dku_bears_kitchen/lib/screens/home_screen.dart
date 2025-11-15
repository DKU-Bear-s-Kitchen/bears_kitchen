import 'package:flutter/material.dart';
import 'package:dku_bears_kitchen/screens/menu_screen.dart';
import 'package:dku_bears_kitchen/screens/review_screen.dart'; // (메뉴 클릭 시 필요)

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- ('가짜' 데이터) ---
  final List<Map<String, String>> allStores = [
    { 'name': '바비든든', 'tags': 'all', 'price': '', 'rating': '4.5 (120)' },
    { 'name': '경성카츠', 'tags': 'all', 'price': '', 'rating': '4.2 (89)' },
    { 'name': '폭풍분식', 'tags': 'all', 'price': '', 'rating': '4.2 (89)' },
  ];
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

  // --- ('기억' 변수) ---
  int _bottomNavIndex = 1;
  String _selectedTab = '전체';
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  // --- ('껍데기' - 'ChoiceChip' 헬퍼 함수) ---
  Widget _buildChip(String label) {
    bool isSelected = _selectedTab == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        // ('두뇌' - '행동' 로직)
        setState(() {
          _selectedTab = label;
          _searchText = '';
          _searchController.clear();
        });
      },
      backgroundColor: Color(0xFFFFFFFF),
      selectedColor: Color(0xFF1F2937),
      labelStyle: TextStyle(
        color: isSelected ? Color(0xFFFFFFFF) : Color(0xFF1F2937),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Color(0xFFE5E7EB)),
      ),
      showCheckmark: false,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- ('두뇌' - '필터링' 로직) ---
    List<Map<String, String>> displayedList;
    bool isShowingStores;

    if (_searchText.isNotEmpty) {
      isShowingStores = false;
      displayedList = allMenus.where((menu) {
        return menu['name']!.toLowerCase().contains(_searchText.toLowerCase());
      }).toList();
    } else if (_selectedTab == '새 메뉴') {
      isShowingStores = false;
      displayedList = allMenus.where((menu) => menu['tags']!.contains('new')).toList();
    } else if (_selectedTab == '인기 메뉴') {
      isShowingStores = false;
      displayedList = allMenus.where((menu) => menu['tags']!.contains('popular')).toList();
    } else {
      isShowingStores = true;
      displayedList = allStores;
    }

    // --- ('껍데기' - '디자인') ---
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.restaurant_menu),
            SizedBox(width: 8),
            Text(
              "Bear's Kitchen",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF1F2937),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController, // '기억' 변수(리모컨) 사용
              onChanged: (value) {
                setState(() { // '행동' 로직
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: "메뉴를 검색해보세요",
                prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildChip('전체'),
                SizedBox(width: 8),
                _buildChip('새 메뉴'),
                SizedBox(width: 8),
                _buildChip('인기 메뉴'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedList.length, // '필터링'된 리스트 사용
              itemBuilder: (context, index) {
                final item = displayedList[index];
                return GestureDetector(
                  onTap: () { // '행동' 로직
                    if (isShowingStores) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(
                            storeName: item['name']!,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewScreen(
                            menuName: item['name']!,
                            menuPrice: item['price']!,
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                    // (이하 Card 디자인...)
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 1.0,
                      ),
                    ),
                    color: Color(0xFFFFFFFF),
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 240,
                          width: double.infinity,
                          color: Color(0xFFF9FAFB),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFD1D5DB),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['name']!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      item['rating']!,
                                      style: TextStyle(
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        currentIndex: _bottomNavIndex, // '기억' 변수 사용
        onTap: (index) { // '행동' 로직
          setState(() {
            _bottomNavIndex = index;
          });
        },
        selectedItemColor: Color(0xFF1F2937),
        unselectedItemColor: Color(0xFF6B7280),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'AI 추천',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '메뉴',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}