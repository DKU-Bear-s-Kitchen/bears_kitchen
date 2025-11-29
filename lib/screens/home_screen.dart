import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dku_bears_kitchen/controllers/home_controller.dart';
import 'package:dku_bears_kitchen/screens/menu_screen.dart';
import 'package:dku_bears_kitchen/screens/review_screen.dart';
// ✅ 새로 만든 AI 추천 화면 import
import 'package:dku_bears_kitchen/screens/ai_recommend_screen.dart';

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
    final controller = Provider.of<HomeController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      // ✅ AppBar 조건부 표시: '메뉴(홈)' 탭(인덱스 1)일 때만 검색창이 있는 AppBar를 보여줍니다.
      // AI 추천 탭이나 내 정보 탭에서는 각 화면의 디자인을 따릅니다.
      appBar: controller.bottomNavIndex == 1
          ? AppBar(
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
            )
          : null, // 1번 탭이 아니면 AppBar 숨김 (null)

      // ✅ [핵심] 하단 탭 번호에 따라 보여줄 화면(Body)을 결정하는 함수 호출
      body: _buildBody(context, controller),

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

  /// ✅ 탭 인덱스에 따라 다른 화면을 리턴하는 함수
  Widget _buildBody(BuildContext context, HomeController controller) {

    switch (controller.bottomNavIndex) {
      case 0: // 💡 1번 탭: AI 추천 화면
        return const AiRecommendScreen();

      case 1: // 🏠 2번 탭: 메뉴 목록 (기존 홈 화면 로직)
        // 리스트 데이터 가져오기
        List<Map<String, dynamic>> displayedList = controller.displayedList;
        bool isShowingStores = controller.isShowingStores;

        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // 상단 필터 칩
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildChip('전체', controller.selectedTab == '전체', () => controller.onTabSelected('전체')),
                  const SizedBox(width: 8),
                  _buildChip('새 메뉴', controller.selectedTab == '새 메뉴', () => controller.onTabSelected('새 메뉴')),
                  const SizedBox(width: 8),
                  _buildChip('인기 메뉴', controller.selectedTab == '인기 메뉴', () => controller.onTabSelected('인기 메뉴')),
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
                              // 식당 클릭 -> 메뉴 목록 화면
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
                              // 메뉴 클릭 -> 리뷰 화면
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewScreen(
                                    storeId: item['storeId'].toString(),
                                    menuId: item['id'].toString(),
                                    menuName: item['name'].toString(),
                                    menuPrice: item['price'].toString(),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
                            ),
                            color: const Color(0xFFFFFFFF),
                            elevation: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 180,
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
                                      top: BorderSide(color: Color(0xFFD1D5DB), width: 1.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              item['rating'].toString(),
                                              style: const TextStyle(color: Color(0xFF4B5563)),
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
        );

      case 2: // 👤 3번 탭: 내 정보 (준비 중)
        return const Center(
          child: Text("내 정보 화면은 아직 준비 중입니다."),
        );

      default:
        return const Center(child: Text("Error"));
    }
  }
}