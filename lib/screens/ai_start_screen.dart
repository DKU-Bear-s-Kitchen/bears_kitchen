// lib/screens/ai_start_screen.dart

// 기존 임포트 외 추가
import '../services/api_service.dart'; 
import '../models/recipe.dart'; 

// ... (StatefulWidget 및 _AIStartScreenState 정의는 동일)

class _AIStartScreenState extends State<AIStartScreen> {
  // ... (기존 _allIngredients, _selectedIngredientIds, _toggleIngredient 정의 동일)
  final ApiService _apiService = ApiService(); // ApiService 인스턴스 생성
  bool _isLoading = false; // 로딩 상태 관리를 위한 변수 추가

  // 4. AI 추천 시작 버튼 클릭 핸들러 (API 호출 로직 추가)
  void _startRecommendation() async {
    if (_selectedIngredientIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('재료를 하나 이상 선택해 주세요!')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      final selectedIds = _selectedIngredientIds.toList();

      // API 호출: 선택된 재료 ID 목록을 백엔드로 전송
      List<Recipe> recommendedRecipes = await _apiService.getRecommendedRecipes(selectedIds);
      
      // 성공: 결과 화면으로 이동하며 레시피 데이터 전달
      // 라우팅 시 arguments를 사용하여 데이터 전달
      Navigator.pushNamed(
        context, 
        '/result', 
        arguments: recommendedRecipes,
      );

    } catch (e) {
      // 오류 발생 시 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추천 로딩 실패: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기존 build 메서드 상단 UI 코드 동일

    return Scaffold(
      // 기존 AppBar, Text 위젯 동일
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // 기존 텍스트, Wrap 위젯 영역 동일
            Expanded(
              child: SingleChildScrollView(
                // 기존 Wrap 위젯 동일
              ),
            ),
            
            // 하단 AI 추천 시작 버튼 (로딩 인디케이터 추가)
            _isLoading
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)) // 로딩 중일 때
                : CustomButton( // 로딩 중이 아닐 때
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