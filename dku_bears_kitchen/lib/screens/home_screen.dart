import 'package:flutter/material.dart';
import 'package:dku_bears_kitchen/screens/menu_screen.dart';
import 'package:dku_bears_kitchen/screens/review_screen.dart';
import 'package:provider/provider.dart';
import 'package:dku_bears_kitchen/controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {

  HomeScreen({super.key});
  //탭(전체, 새 메뉴, 인기 메뉴) 버튼
  Widget _buildChip(String label, bool isSelected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        onSelected(); 
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
    final controller = Provider.of<HomeController>(context);

    List<Map<String, String>> displayedList = controller.displayedList;
    bool isShowingStores = controller.isShowingStores;

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
        // 검색창
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) {
                controller.onSearchChanged(value); 
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
                _buildChip(
                  '전체',
                  controller.selectedTab == '전체', 
                  () => controller.onTabSelected('전체'), 
                ),
                SizedBox(width: 8),
                _buildChip(
                  '새 메뉴',
                  controller.selectedTab == '새 메뉴',
                  () => controller.onTabSelected('새 메뉴'),
                ),
                SizedBox(width: 8),
                _buildChip(
                  '인기 메뉴',
                  controller.selectedTab == '인기 메뉴',
                  () => controller.onTabSelected('인기 메뉴'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedList.length, 
              itemBuilder: (context, index) {
                final item = displayedList[index];
                return GestureDetector(
                  onTap: () {
                    //식당을 클릭하면 메뉴 화면으로 이동
                    if (isShowingStores) { 
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(
                            storeId: item['id']!,
                            storeName: item['name']!,
                          ),
                        ),
                      );
                    } else {
                      //메뉴를 클릭하면 리뷰 화면으로 이동
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
                  //식당/메뉴 카드
                  child: Card(
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
                                //식당 이름 및 별점 가져와서 표시
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
        currentIndex: controller.bottomNavIndex, 
        onTap: (index) {
          controller.onBottomNavTap(index);
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