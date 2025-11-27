// my_info_screen.dart

import 'package:flutter/material.dart';

class MyInfoScreen extends StatelessWidget {
  // 실제 앱에서는 이 데이터들이 사용자 인증/DB에서 로드
  final String userName = '김단국';
  final String userStatus = '단국대학교 학생';
  final int reviewsWritten = 12;
  final double averageRating = 4.5;
  
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보', style: TextStyle(fontWeight: FontWeight.bold)),
        // 시안에는 뒤로가기 버튼이 없으므로, 기본으로 두고 제목만 설정
      ),
      // 시안에 하단 탭 바가 있지만, 화면 내용에 집중하여 바디 부분만 작성합니다.
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 사용자 프로필 및 기본 정보 섹션
            _buildProfileSection(context),
            
            // 2. 활동 지표 (쓴 리뷰, 평균 별점) 섹션
            _buildActivityMetrics(),
            
            const Divider(height: 1, thickness: 1),
            
            // 3. 마이페이지 네비게이션 목록
            _buildNavigationList(context),
          ],
        ),
      ),
    );
  }

  // 사용자 프로필 이미지, 이름, 상태를 표시하는 위젯
  Widget _buildProfileSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // 프로필 이미지 (시안에 따라 원형 플레이스홀더 사용)
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey, // 배경색을 회색으로 설정
            child: Icon(Icons.person, size: 40, color: Colors.white), // 아이콘 또는 실제 이미지 로드
          ),
          const SizedBox(width: 15),
          // 이름 및 상태
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userStatus,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 쓴 리뷰 수와 평균 별점을 표시하는 위젯
  Widget _buildActivityMetrics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metricItem('쓴 리뷰', reviewsWritten.toString(), Icons.rate_review),
          _metricItem('평균 별점', averageRating.toString(), Icons.star),
        ],
      ),
    );
  }

  // 단일 지표 아이템 위젯
  Widget _metricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘은 추가 가능
            // Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: Color(0xFFE48D2A) // 임의의 강조색
          ), 
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // 네비게이션 리스트를 구성하는 위젯
  Widget _buildNavigationList(BuildContext context) {
    return Column(
      children: [
        _buildListTile(context, '내가 쓴 리뷰', Icons.reviews, () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => MyReviewsScreen()));
        }),
        _buildListTile(context, '공지사항', Icons.campaign, () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => NoticeScreen()));
        }),
        _buildListTile(context, '설정', Icons.settings, () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
        }),
        // 로그아웃은 중요한 액션임을 강조하기 위해 색상을 다르게 적용
        _buildListTile(context, '로그아웃', Icons.logout, () {
          // 로그아웃 로직 (예: FirebaseAuth.instance.signOut())
        }, isLogout: true),
      ],
    );
  }

  // 커스텀 ListTile 위젯
  Widget _buildListTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      // 아이콘 추가
      // leading: Icon(icon, color: isLogout ? Colors.pink : Colors.black), 
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
          color: isLogout ? Colors.pink.shade700 : Colors.black, // 로그아웃 강조 색상 적용
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
      onTap: onTap,
    );
  }
}