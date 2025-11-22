import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dku_bears_kitchen/controllers/home_controller.dart';
// 아래 스크린 파일들이 실제로 존재하는지 확인해주세요.
import 'package:dku_bears_kitchen/screens/menu_screen.dart';
import 'package:dku_bears_kitchen/screens/review_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 탭(전체, 새 메뉴, 인기 메뉴) 버튼 위젯
  Widget _buildChip(String label, bool isSelected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        onSelected();
      },
      backgroundColor: const Color(0xFFFFFFFF),
      selectedColor: const Color(0xFF1F2937),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF1F2937),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통해 컨트롤러 가져오기
    final controller = Provider.of<HomeController>(context);

    // 🔥 [변경] Firebase 데이터는 String뿐만 아니라 dynamic 타입이므로 변경
    List<Map<String, dynamic>> displayedList = controller.displayedList;
    bool isShowingStores = controller.isShowingStores;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          children: const [
             Icon(Icons.restaurant_menu),
             SizedBox(width: 8),
             Text(
              "Bear's Kitchen",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        // 검색창
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) {
                controller.onSearchChanged(value);
              },
              decoration: InputDecoration(
                hintText: "메뉴를 검색해보세요",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),

      // 🔥 [추가] 로딩 중이면 뱅글뱅글 로딩바 표시
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 상단 필터 칩 (전체 / 새 메뉴 / 인기 메뉴)
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
                      const SizedBox(width: 8),
                      _buildChip(
                        '새 메뉴',
                        controller.selectedTab == '새 메뉴',
                        () => controller.onTabSelected('새 메뉴'),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        '인기 메뉴',
                        controller.selectedTab == '인기 메뉴',
                        () => controller.onTabSelected('인기 메뉴'),
                      ),
                    ],
                  ),
                ),

                // 리스트 뷰
                Expanded(
                  child: displayedList.isEmpty
                      ? const Center(child: Text("검색 결과가 없습니다."))
                      : ListView.builder(
                          itemCount: displayedList.length,
                          itemBuilder: (context, index) {
                            final item = displayedList[index];
                            return GestureDetector(
                              onTap: () {
                                if (isShowingStores) {
                                  // 식당 클릭 -> 메뉴 목록 화면 (id 전달)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MenuScreen(
                                        storeId: item['id'].toString(),
                                        storeName: item['name'].toString(),
                                      ),
                                    ),
                                  );
                                } else {
                                  // 메뉴 클릭 -> 리뷰 화면 (이름, 가격 전달)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewScreen(
                                        storeId: item['storeId'].toString(), // 👈 추가됨
                                        menuId: item['id'].toString(),       // 👈 추가됨
                                        menuName: item['name'].toString(),
                                        menuPrice: item['price'].toString(),
                                      ),
                                    ),
                                  );
                                }
                              },
                              // 식당/메뉴 카드 디자인
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Color(0xFFD1D5DB),
                                    width: 1.0,
                                  ),
                                ),
                                color: const Color(0xFFFFFFFF),
                                elevation: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 이미지 영역 (현재는 회색 박스 + 아이콘)
                                    Container(
                                      height: 180, // 높이를 약간 줄임
                                      width: double.infinity,
                                      color: const Color(0xFFF3F4F6),
                                      child: const Center(
                                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Color(0xFFD1D5DB),
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // 이름
                                            Text(
                                              item['name'].toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1F2937),
                                              ),
                                            ),
                                            // 별점 (HomeController에서 임시로 넣어준 값 사용)
                                            Row(
                                              children: [
                                                const Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item['rating'].toString(),
                                                  style: const TextStyle(
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
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.bottomNavIndex,
        onTap: (index) {
          controller.onBottomNavTap(index);
        },
        selectedItemColor: const Color(0xFF1F2937),
        unselectedItemColor: const Color(0xFF6B7280),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
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