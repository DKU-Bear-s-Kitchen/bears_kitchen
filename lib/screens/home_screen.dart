import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dku_bears_kitchen/controllers/home_controller.dart';
import 'package:dku_bears_kitchen/screens/menu_screen.dart';
import 'package:dku_bears_kitchen/screens/review_screen.dart';
import 'package:dku_bears_kitchen/screens/ai_recommend_screen.dart';
import 'package:dku_bears_kitchen/screens/my_page_screen.dart';
import 'package:dku_bears_kitchen/widgets/menu_image.dart';
import 'package:dku_bears_kitchen/widgets/filter_modal.dart'; // ✅ 필터 모달 import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      appBar: controller.bottomNavIndex == 1
          ? AppBar(
              title: Row(
                children: const [
                   Icon(Icons.restaurant_menu),
                   SizedBox(width: 8),
                   Text("Bear's Kitchen", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              backgroundColor: const Color(0xFFFFFFFF),
              foregroundColor: const Color(0xFF1F2937),
              elevation: 0,
              // 🔥 [추가] 필터 버튼
              actions: [
                IconButton(
                  icon: const Icon(Icons.tune), // 조절 아이콘
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const FilterModal(),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) => controller.onSearchChanged(value),
                    decoration: InputDecoration(
                      hintText: "메뉴를 검색해보세요",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: _buildBody(context, controller),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 4,
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.bottomNavIndex,
        onTap: (index) => controller.onBottomNavTap(index),
        selectedItemColor: const Color(0xFF1F2937),
        unselectedItemColor: const Color(0xFF6B7280),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'AI 추천'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '메뉴'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '내 정보'),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeController controller) {
    switch (controller.bottomNavIndex) {
      case 0: return const AiRecommendScreen();
      case 1:
        List<Map<String, dynamic>> displayedList = controller.displayedList;
        bool isShowingStores = controller.isShowingStores;

        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
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
            Expanded(
              child: displayedList.isEmpty
                  ? const Center(child: Text("검색 결과가 없습니다."))
                  : ListView.builder(
                      itemCount: displayedList.length,
                      itemBuilder: (context, index) {
                        final item = displayedList[index];
                        // 🔥 메뉴인지 식당인지 확인 (메뉴면 가격이 있음)
                        final bool isMenu = item.containsKey('priceStr');

                        return GestureDetector(
                          onTap: () {
                            if (isShowingStores) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MenuScreen(storeId: item['id'].toString(), storeName: item['name'].toString())));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewScreen(storeId: item['storeId'].toString(), menuId: item['id'].toString(), menuName: item['name'].toString(), menuPrice: item['priceStr'].toString())));
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.0)),
                            color: const Color(0xFFFFFFFF),
                            elevation: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 180,
                                  width: double.infinity,
                                  child: MenuImage(
                                    menuName: item['name'].toString(),
                                    size: 180,
                                    borderRadius: 0,
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFD1D5DB), width: 1.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 이름
                                        Text(item['name'].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),

                                        // 우측 정보 (별점 + 가격)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Row(children: [const Icon(Icons.star, color: Color(0xFFFACC15), size: 16), const SizedBox(width: 4), Text(item['rating'].toString(), style: const TextStyle(color: Color(0xFF4B5563)))]),

                                            // 🔥 [추가] 메뉴일 때만 가격 표시
                                            if (isMenu)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Text(item['priceStr'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
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

      case 2: return const MyPageScreen();
      default: return const Center(child: Text("Error"));
    }
  }
}