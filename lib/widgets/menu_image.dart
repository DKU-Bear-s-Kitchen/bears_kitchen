import 'package:flutter/material.dart';

class MenuImage extends StatelessWidget {
  final String menuName;
  final double size;
  final double borderRadius;

  const MenuImage({
    super.key,
    required this.menuName,
    this.size = 80,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBackgroundColor(menuName),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Icon(
          _getIcon(menuName),
          size: size * 0.5,
          color: Colors.white.withOpacity(0.95),
        ),
      ),
    );
  }

  // 🎨 메뉴 이름에 맞춰 색상 결정 (학식 메뉴판 맞춤형)
  Color _getBackgroundColor(String name) {
    // 1. 빨강/주황 계열 (매운 국물, 떡볶이, 짬뽕)
    if (name.contains('찌개') || name.contains('육개장') || name.contains('얼큰') ||
        name.contains('짬뽕') || name.contains('떡볶이') || name.contains('김치') ||
        name.contains('마라') || name.contains('부대')) {
      return const Color(0xFFFF8A80); // Red Accent
    }
    // 2. 뚝배기/국밥 계열 (진한 국물)
    else if (name.contains('국밥') || name.contains('곰탕') || name.contains('순대') ||
             name.contains('된장') || name.contains('해장')) {
      return const Color(0xFFD7CCC8); // 연한 갈색 (뚝배기 느낌)
    }
    // 3. 밥/카레/분식 계열 (노랑/주황)
    else if (name.contains('밥') || name.contains('죽') || name.contains('카레') ||
             name.contains('오므라이스') || name.contains('콘치즈') || name.contains('계란') ||
             name.contains('알밥')) {
      return const Color(0xFFFFD180); // Orange Accent
    }
    // 4. 면 요리 (민트/청록)
    else if (name.contains('면') || name.contains('국수') || name.contains('우동') ||
             name.contains('라면') || name.contains('쫄면') || name.contains('짜장') ||
             name.contains('칼국수')) {
      return const Color(0xFF80CBC4); // Teal
    }
    // 5. 고기/튀김/만두 (갈색)
    else if (name.contains('고기') || name.contains('돈까스') || name.contains('카츠') ||
             name.contains('제육') || name.contains('불고기') || name.contains('갈비') ||
             name.contains('탕수육') || name.contains('만두') || name.contains('튀김') ||
             name.contains('직화') || name.contains('편육') || name.contains('춘권') || name.contains('빠스')) {
      return const Color(0xFFA1887F); // Brown
    }
    // 6. 음료 (하늘색)
    else if (name.contains('음료') || name.contains('콜라') || name.contains('사이다')) {
      return const Color(0xFF90CAF9); // Light Blue
    }

    // 7. 그 외 (이름에 따라 고정된 랜덤 파스텔톤)
    final List<Color> palette = [
      const Color(0xFF90CAF9), // Blue
      const Color(0xFFCE93D8), // Purple
      const Color(0xFFFFAB91), // Deep Orange
      const Color(0xFFB0BEC5), // Blue Grey
      const Color(0xFFE6EE9C), // Lime
      const Color(0xFFFFF59D), // Yellow
      const Color(0xFF80DEEA), // Cyan
      const Color(0xFFB39DDB), // Deep Purple
    ];
    return palette[name.hashCode.abs() % palette.length];
  }

  // 🍴 메뉴 이름에 맞춰 아이콘 결정
  IconData _getIcon(String name) {
    // 국물/뚝배기
    if (name.contains('찌개') || name.contains('탕') || name.contains('국') ||
        name.contains('개장') || name.contains('짬뽕')) return Icons.soup_kitchen;

    // 밥류
    if (name.contains('밥') || name.contains('카레') || name.contains('죽') ||
        name.contains('오므라이스')) return Icons.rice_bowl;

    // 면류
    if (name.contains('면') || name.contains('우동') || name.contains('국수') ||
        name.contains('파스타') || name.contains('라면') || name.contains('짜장')) return Icons.ramen_dining;

    // 분식/사이드
    if (name.contains('떡볶이')) return Icons.local_dining;
    if (name.contains('만두') || name.contains('춘권')) return Icons.tapas; // 만두 느낌 아이콘 대체
    if (name.contains('튀김') || name.contains('빠스')) return Icons.fastfood;
    if (name.contains('콘치즈')) return Icons.local_pizza; // 치즈 느낌

    // 고기/메인요리
    if (name.contains('고기') || name.contains('돈까스') || name.contains('카츠') ||
        name.contains('갈비') || name.contains('제육') || name.contains('불고기') ||
        name.contains('탕수육') || name.contains('직화') || name.contains('편육') ||
        name.contains('함박')) return Icons.restaurant;

    // 음료
    if (name.contains('음료') || name.contains('콜라')) return Icons.local_drink;
    if (name.contains('카페') || name.contains('커피')) return Icons.local_cafe;

    // 기본값
    return Icons.restaurant_menu;
  }
}