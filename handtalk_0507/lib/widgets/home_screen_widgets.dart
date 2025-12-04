import 'package:flutter/material.dart';

class TodayLessonCard extends StatelessWidget {
  const TodayLessonCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // 이미지 컨테이너의 높이와 패딩을 수정했습니다.
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                width: double.infinity,
                height: 150, // 높이를 150으로 수정했습니다.
                color: Colors.black12,
                child: Image.asset(
                  'assets/images/handNimber.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        '이미지를 불러오는데 실패했습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '손가락 번호',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '수어동작 설명시 사용되는 손가락 번호입니다.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
