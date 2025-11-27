// lib/screens/ai_start_screen.dart

import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/ingredient_chip.dart';
import '../models/ingredient.dart'; // Ingredient 모델 import

class AIStartScreen extends StatefulWidget {
  const AIStartScreen({super.key});

  @override
  State<AIStartScreen> createState() => _AIStartScreenState();
}

class _AIStartScreenState extends State<AIStartScreen> {
  // 1. 선택 가능한 전체 재료 목록 (임시 데이터)
  final List<Ingredient> _allIngredients = [
    Ingredient(id: '1', name: '돼지고기'),
    Ingredient(id: '2', name: '김치'),
    Ingredient(id: '3', name: '두부'),
    Ingredient(id: '4', name: '양파'),
    Ingredient(id: '5', name: '감자'),
    Ingredient(id: '6', name: '달걀'),
    Ingredient(id: '7', name: '참치'),
    Ingredient(id: '8', name: '쌀'),
    Ingredient(id: '9', name: '파'),
    Ingredient(id: '10', name: '간장'),
    // 더 많은 재료 추가 가능
  ];

  // 2. 사용자가 선택한 재료 ID 목록
  final Set<String> _selectedIngredientIds = {};

  // 3. 재료 선택/해제 로직
  void _toggleIngredient(String ingredientId) {
    setState(() {
      if (_selectedIngredientIds.contains(ingredientId)) {
        _selectedIngredientIds.remove(ingredientId); // 이미 선택되어 있으면 해제
      } else {
        _selectedIngredientIds.add(ingredientId); // 선택 안 되어 있으면 추가
      }
    });
  }

  // 4. AI 추천 시작 버튼 클릭 핸들러
  void _startRecommendation() {
    if (_selectedIngredientIds.isEmpty) {
      // 재료를 선택하지 않았을 경우 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재료를 하나 이상 선택해 주세요!')),
      );
      return;
    }
    
    // 선택된 재료 목록을 백엔드 API로 전송하는 로직 추가
    
    // API 응답을 기다린 후, 결과 화면으로 이동
    Navigator.pushNamed(context, '/result'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 레시피 추천'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '냉장고 속 재료를 선택해 주세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '선택한 재료를 기반으로 레시피를 추천해 드립니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 칩 목록을 보여주는 영역
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10.0, // 가로 간격
                  runSpacing: 10.0, // 세로 줄 간격
                  children: _allIngredients.map((ingredient) {
                    final isSelected = _selectedIngredientIds.contains(ingredient.id);
                    return IngredientChip(
                      name: ingredient.name,
                      isSelected: isSelected,
                      onTap: () => _toggleIngredient(ingredient.id), // 선택/해제 토글
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // 하단 AI 추천 시작 버튼
            CustomButton(
              text: 'AI 추천 시작하기 (${_selectedIngredientIds.length}개 선택)',
              onPressed: _startRecommendation,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}