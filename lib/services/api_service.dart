// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  // 백엔드 API의 기본 주소 (팀 주소로 변경 필요)
  static const String _baseUrl = 'http://10.0.2.2:8080/api';

  // 재료 ID 목록을 받아 레시피를 요청하는 함수
  Future<List<Recipe>> getRecommendedRecipes(List<String> ingredientIds) async {
    final url = Uri.parse('$_baseUrl/recipes/recommend'); // 예시 API 엔드포인트
    
    // 요청 본문 (선택된 재료 ID 목록을 JSON 형태로 보냄)
    final body = jsonEncode({
      'ingredientIds': ingredientIds,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // 성공적으로 응답을 받았을 경우
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        
        // JSON 리스트를 Recipe 모델 리스트로 변환하여 반환
        return jsonList.map((json) => Recipe.fromJson(json)).toList();
      } else {
        // 서버에서 오류 응답
        print('Failed to load recipes: ${response.statusCode}');
        throw Exception('레시피 로드 실패. 서버 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 연결 오류 등
      print('API 통신 오류 발생: $e');
      throw Exception('네트워크 오류 또는 데이터 처리 실패: $e');
    }
  }
}