import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dku_bears_kitchen/controllers/home_controller.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late List<String> _tempSelectedStores;
  late RangeValues _tempPriceRange;
  late double _tempMinRating;
  late String _tempSortOption;

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<HomeController>(context, listen: false);
    _tempSelectedStores = List.from(controller.selectedStoreIds);
    _tempPriceRange = controller.priceRange;
    _tempMinRating = controller.minRating;
    _tempSortOption = controller.sortOption;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context, listen: false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempSelectedStores = [];
                      _tempPriceRange = const RangeValues(0, 20000);
                      _tempMinRating = 0.0;
                      _tempSortOption = '기본순';
                    });
                  },
                  child: const Text("초기화", style: TextStyle(color: Colors.grey)),
                ),
                const Text("필터 및 정렬", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          const Divider(height: 1),

          // 옵션들
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("정렬 기준"),
                  Wrap(
                    spacing: 8,
                    children: ['기본순', '가격 낮은순', '가격 높은순', '별점 높은순', '리뷰 많은순'].map((option) {
                      final isSelected = _tempSortOption == option;
                      return ChoiceChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _tempSortOption = option),
                        selectedColor: const Color(0xFF1F2937),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        backgroundColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("가격대 (${_tempPriceRange.start.round()}원 ~ ${_tempPriceRange.end.round()}원)"),
                  RangeSlider(
                    values: _tempPriceRange,
                    min: 0,
                    max: 20000,
                    divisions: 20,
                    activeColor: const Color(0xFF1F2937),
                    labels: RangeLabels("${_tempPriceRange.start.round()}", "${_tempPriceRange.end.round()}"),
                    onChanged: (values) => setState(() => _tempPriceRange = values),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("최소 별점 (${_tempMinRating.toStringAsFixed(1)}점 이상)"),
                  Slider(
                    value: _tempMinRating,
                    min: 0.0, max: 5.0, divisions: 10,
                    activeColor: const Color(0xFFFACC15),
                    label: _tempMinRating.toString(),
                    onChanged: (val) => setState(() => _tempMinRating = val),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("식당 선택"),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.allStores.map((store) {
                      final isSelected = _tempSelectedStores.contains(store['id']);
                      return FilterChip(
                        label: Text(store['name']),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) _tempSelectedStores.add(store['id']);
                            else _tempSelectedStores.remove(store['id']);
                          });
                        },
                        selectedColor: const Color(0xFF1F2937).withOpacity(0.1),
                        checkmarkColor: const Color(0xFF1F2937),
                        labelStyle: TextStyle(
                          color: isSelected ? const Color(0xFF1F2937) : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // 적용 버튼
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  controller.setStoreFilter(_tempSelectedStores);
                  controller.setPriceFilter(_tempPriceRange);
                  controller.setRatingFilter(_tempMinRating);
                  controller.setSortOption(_tempSortOption);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("필터 적용하기", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}