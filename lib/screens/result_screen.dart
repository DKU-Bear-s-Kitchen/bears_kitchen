// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigator를 통해 전달된 레시피 리스트를 받기
    final List<Recipe>? recommendedRecipes = 
        ModalRoute.of(context)!.settings.arguments as List<Recipe>?;

    // 만약 데이터가 없거나 비어 있다면
    if (recommendedRecipes == null || recommendedRecipes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI 추천 레시피')),
        body: const Center(
          child: Text('선택한 재료로는 레시피를 추천할 수 없습니다.', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 추천 레시피'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: recommendedRecipes.length,
        itemBuilder: (context, index) {
          final recipe = recommendedRecipes[index];
          return RecipeCard(
            recipe: recipe,
            onTap: () {
              // 레시피 상세 화면으로 이동 로직 (추후 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${recipe.title} 상세 보기로 이동합니다.')),
              );
            },
          );
        },
      ),
    );
  }
}