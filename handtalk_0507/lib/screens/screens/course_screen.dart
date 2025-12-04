import 'package:flutter/material.dart';
import 'package:handtalk/screens/screens/sign_language_webview.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  // 웹뷰에 사용할 URL들
  static const String dailyLifeBaseUrl =
      'https://sldict.korean.go.kr/front/sign/signList.do?top_category=CTE';
  static const String professionalBaseUrl =
      'https://sldict.korean.go.kr/front/sign/signList.do?top_category=SPE';
  static const String cultureBaseUrl =
      'https://sldict.korean.go.kr/front/museum/museumList.do';

  // 단어 클릭 시 웹뷰 화면으로 이동하는 함수
  void _navigateToWebView(String title, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignLanguageWebView(title: title, url: url),
      ),
    );
  }

  // 그리드 형태의 카테고리 버튼 위젯
  Widget _buildGridCategoryButton(
      IconData icon, String label, String categoryId,
      {bool isMuseum = false, bool isDailyLife = false}) {
    final url = isDailyLife
        ? '$dailyLifeBaseUrl&category=$categoryId'
        : isMuseum
            ? '$cultureBaseUrl?top_category=MUE&category=$categoryId' // 'museum_cd' 대신 'category' 사용
            : '$professionalBaseUrl&category=$categoryId';

    return InkWell(
      onTap: () {
        _navigateToWebView(label, url);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, size: 40, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 일상생활 수어 섹션
            const Text('일상생활 수어',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildGridCategoryButton(Icons.person_outline, '인간', 'CTE001',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.local_cafe_outlined, '삶', 'CTE002',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.restaurant_outlined, '식생활', 'CTE003',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.checkroom_outlined, '의생활', 'CTE004',
                    isDailyLife: true),
                _buildGridCategoryButton(Icons.home_outlined, '주생활', 'CTE005',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.groups_outlined, '사회생활', 'CTE006',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.payments_outlined, '경제생활', 'CTE007',
                    isDailyLife: true),
                _buildGridCategoryButton(Icons.book_outlined, '교육', 'CTE008',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.map_outlined, '나라명 및 지명', 'CTE009',
                    isDailyLife: true),
                _buildGridCategoryButton(Icons.church_outlined, '종교', 'CTE010',
                    isDailyLife: true),
                _buildGridCategoryButton(Icons.palette_outlined, '문화', 'CTE011',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.gavel_outlined, '정치와 행정', 'CTE012',
                    isDailyLife: true),
                _buildGridCategoryButton(Icons.eco_outlined, '자연', 'CTE013',
                    isDailyLife: true),
                _buildGridCategoryButton(Icons.pets_outlined, '동식물', 'CTE014',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.lightbulb_outline, '개념', 'CTE015',
                    isDailyLife: true),
                _buildGridCategoryButton(
                    Icons.more_horiz_outlined, '기타', 'CTE016',
                    isDailyLife: true),
              ],
            ),
            const SizedBox(height: 24),
            // 전문용어 수어 섹션
            const Text('전문용어 수어',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildGridCategoryButton(Icons.gavel, '법률', 'SPE001'),
                _buildGridCategoryButton(Icons.directions_bus, '교통', 'SPE002'),
                _buildGridCategoryButton(
                    Icons.medical_services, '의학', 'SPE003'),
                _buildGridCategoryButton(Icons.computer, '정보통신', 'SPE004'),
                _buildGridCategoryButton(Icons.balance, '불교', 'SPE005'),
                _buildGridCategoryButton(Icons.castle, '천주교', 'SPE006'),
                _buildGridCategoryButton(Icons.church, '기독교', 'SPE007'),
                _buildGridCategoryButton(Icons.book, '국어 교과 용어', 'SPE008'),
                _buildGridCategoryButton(Icons.attach_money, '경제', 'SPE009'),
                _buildGridCategoryButton(Icons.group, '정치', 'SPE010'),
              ],
            ),
            const SizedBox(height: 24),
            // 문화정보 수어 섹션
            const Text('문화정보 수어',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildGridCategoryButton(
                    Icons.account_balance, '국립중앙박물관', 'MUE001',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.museum, '국립민속박물관', 'MUE002',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.text_fields, '국립한글박물관', 'MUE003',
                    isMuseum: true),
                _buildGridCategoryButton(
                    Icons.location_city, '국립경주박물관', 'MUE004',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.location_on, '국립공주박물관', 'MUE005',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.park, '국립부여박물관', 'MUE006',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.landscape, '국립진주박물관', 'MUE007',
                    isMuseum: true),
                _buildGridCategoryButton(
                    Icons.castle_outlined, '대한민국역사박물관', 'MUE008',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.science, '국립과천과학관', 'MUE009',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.place, '국립광주박물관', 'MUE010',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.local_offer, '국립김해박물관', 'MUE011',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.business, '국립대구박물관', 'MUE012',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.grass, '국립전주박물관', 'MUE013',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.flag, '국립제주박물관', 'MUE014',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.villa, '국립청주박물관', 'MUE015',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.apartment, '부산시립박물관', 'MUE016',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.forest, '국립나주박물관', 'MUE017',
                    isMuseum: true),
                _buildGridCategoryButton(Icons.train, '국립춘천박물관', 'MUE018',
                    isMuseum: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
