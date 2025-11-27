// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  // 임시 레시피 데이터 (실제로는 API 호출 결과로 대체)
  final List<Recipe> dummyRecipes = const [
    Recipe(id: '1', title: '매콤 돼지고기 김치찌개', imageUrl: 'https://picsum.photos/600/400?random=1', description: '묵은지와 돼지고기의 환상적인 조합! 얼큰하고 깊은 맛의 김치찌개.'),
    Recipe(id: '2', title: '참치 야채 비빔밥', imageUrl: 'https://picsum.photos/600/400?random=2', description: '간단하고 영양 만점인 비빔밥. 신선한 야채와 고소한 참치가 어우러집니다.'),
    Recipe(id: '3', title: '두부 스테이크와 버섯 소스', imageUrl: 'https://picsum.photos/600/400?random=3', description: '담백한 두부를 구워내고 버섯 소스를 곁들인 건강한 요리.'),
    // 실제 데이터는 API에서 로드될 예정
  ];

  // 레시피 카드 클릭 시 상세 화면으로 이동하는 임시 함수
  void _goToRecipeDetail(BuildContext context, Recipe recipe) {
    // 레시피 상세 화면이 있다면 해당 화면으로 이동하는 로직을 추가
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${recipe.title} 상세 보기로 이동')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 추천 레시피'),
        centerTitle: true,
      ),
      body: dummyRecipes.isEmpty
          ? const Center(child: Text('추천된 레시피가 없습니다.')) // 레시피가 없을 경우
          : ListView.builder(
              itemCount: dummyRecipes.length,
              itemBuilder: (context, index) {
                final recipe = dummyRecipes[index];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () => _goToRecipeDetail(context, recipe),
                );
              },
            ),
    );
  }
}