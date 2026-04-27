import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  int _tabIndex = 0;
  final _tabs = ['Feed', 'Mentors', 'Coaches', 'Stories'];
  final _filters = ['All', 'Breast', 'Chemo', 'Recovery'];
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -40, right: -20,
            child: Container(width: 150, height: 150,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.07), Colors.transparent])))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    RichText(text: TextSpan(style: AppText.displayTitle, children: const [
                      TextSpan(text: 'Your '),
                      TextSpan(text: 'community',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    ])),
                    Text('Coaches, mentors and peers — all in one place',
                      style: AppText.bodySecondary),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.07),
                        borderRadius: AppRadius.fullBR,
                        border: Border.all(
                          color: AppColors.teal.withOpacity(0.18), width: 0.5),
                      ),
                      child: Text('✓ Safe space · Moderated',
                        style: AppText.caption.copyWith(
                          color: AppColors.teal, fontWeight: FontWeight.w500,
                          fontSize: 10)),
                    ),
                  ]),
                ),
                // Tabs
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    children: _tabs.asMap().entries.map((e) {
                      final active = e.key == _tabIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _tabIndex = e.key),
                        child: Container(
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 7),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primaryLight : AppColors.surface,
                            borderRadius: AppRadius.fullBR,
                            border: Border.all(
                              color: active ? AppColors.primaryMid : AppColors.border,
                              width: 0.5),
                          ),
                          child: Text(e.value,
                            style: AppText.caption.copyWith(
                              fontSize: 11, fontWeight: FontWeight.w500,
                              color: active ? AppColors.primary : AppColors.text2,
                            )),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Filter chips (Feed only)
                if (_tabIndex == 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                    child: Row(
                      children: _filters.asMap().entries.map((e) {
                        final active = e.key == _filterIndex;
                        return GestureDetector(
                          onTap: () => setState(() => _filterIndex = e.key),
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary.withOpacity(0.06)
                                  : AppColors.surface,
                              borderRadius: AppRadius.fullBR,
                              border: Border.all(
                                color: active
                                    ? AppColors.primary.withOpacity(0.18)
                                    : AppColors.border,
                                width: 0.5),
                            ),
                            child: Text(e.value,
                              style: AppText.caption.copyWith(
                                fontSize: 10, fontWeight: FontWeight.w500,
                                color: active ? AppColors.primary : AppColors.text3,
                              )),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    child: _tabIndex == 0 ? _buildFeed()
                        : _tabIndex == 1 ? _buildMentors()
                        : _tabIndex == 2 ? _buildCoaches()
                        : _buildStories(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Moderation note
        Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.04),
            borderRadius: AppRadius.mdBR,
            border: Border.all(
              color: AppColors.teal.withOpacity(0.13), width: 0.5),
          ),
          child: Text('🛡️ Peer support only. Always consult your care team.',
            style: AppText.caption.copyWith(
              color: AppColors.teal.withOpacity(0.65), fontSize: 10,
              height: 1.5)),
        ),
        // Weekly prompt
        Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.06),
            borderRadius: AppRadius.mdBR,
            border: Border.all(color: AppColors.blue.withOpacity(0.15), width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('✦ THIS WEEK\'S PROMPT',
              style: AppText.label.copyWith(color: AppColors.blue)),
            const SizedBox(height: 5),
            Text('"What\'s one small thing that helped you through a hard day?"',
              style: AppText.body.copyWith(color: AppColors.text1)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.09),
                borderRadius: AppRadius.fullBR,
                border: Border.all(color: AppColors.blue.withOpacity(0.18), width: 0.5),
              ),
              child: Text('+ Share your answer',
                style: AppText.caption.copyWith(
                  color: AppColors.blue, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
        _buildPost('SJ', AppColors.primaryLight, AppColors.primary,
          'Sarah J.', '2 hours ago · Breast · Week 6',
          'Week 6 done! Morning walks really help — even 10 minutes makes a difference. 🌸',
          24, 12, true),
        _buildPost('MR', AppColors.blueLight, AppColors.blue,
          'Michael R.', '5 hours ago · Colorectal',
          'Waiting for scan results is the hardest part. Sending strength 💜 — the scanxiety is very real.',
          38, 5, true),
        // UAE Support
        const SectionLabel('Support in the UAE'),
        ...[
          ('🏥', 'Tawam Hospital', 'Abu Dhabi · Oncology'),
          ('🎗️', 'Emirates Cancer Society', 'Support & awareness'),
          ('🏥', 'Al Jalila Foundation', 'Dubai · Research'),
          ('🩷', 'Pink Caravan', 'Breast cancer UAE'),
        ].map((s) => Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.mdBR,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(children: [
            Text(s.$1, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.$2, style: AppText.bodySemibold),
                Text(s.$3, style: AppText.bodySecondary),
              ],
            )),
          ]),
        )),
        // Crisis line
        Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 24),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.mdBR,
            border: Border.all(color: AppColors.primaryMid, width: 0.5),
          ),
          child: Column(children: [
            Text('Need support right now?',
              style: AppText.bodySemibold.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text('800 4673',
              style: AppText.statNumber.copyWith(
                color: AppColors.primary, fontSize: 22)),
            Text('Available 24/7 · Free to call · UAE MOHAP Hope Line',
              style: AppText.caption.copyWith(fontSize: 10),
              textAlign: TextAlign.center),
          ]),
        ),
      ],
    );
  }

  Widget _buildPost(String initials, Color avBg, Color avColor,
      String name, String info, String text,
      int likes, int replies, bool liked) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: avBg, shape: BoxShape.circle),
            child: Center(child: Text(initials,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                fontWeight: FontWeight.w500, color: avColor))),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: AppText.bodySemibold),
            Text(info, style: AppText.caption.copyWith(fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 9),
        Text(text, style: AppText.bodySecondary),
        const SizedBox(height: 9),
        Row(children: [
          _reactButton('💜 $likes', liked),
          const SizedBox(width: 6),
          _reactButton('🤝 Me too', false),
          const Spacer(),
          Text('$replies replies', style: AppText.caption.copyWith(fontSize: 10)),
        ]),
      ]),
    );
  }

  Widget _reactButton(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryLight : AppColors.background,
        borderRadius: AppRadius.fullBR,
        border: Border.all(
          color: active ? AppColors.primaryMid : AppColors.border, width: 0.5),
      ),
      child: Text(label,
        style: AppText.caption.copyWith(
          fontSize: 11,
          color: active ? AppColors.primary : AppColors.text2,
        )),
    );
  }

  Widget _buildMentors() {
    final mentors = [
      ('LM', AppColors.goldLight, AppColors.gold, 'Lena M.',
          'Survivor · 4 years free', 'Breast cancer · Dubai',
          'I know what week 6 feels like. I\'m here to listen.', true),
      ('JK', AppColors.primaryLight, AppColors.primary, 'James K.',
          'Survivor · 2 years free', 'Colorectal · Abu Dhabi',
          'Went through chemo twice. Happy to share what helped me.', false),
      ('RA', AppColors.tealLight, AppColors.teal, 'Rania A.',
          'Survivor · 6 years free', 'Breast · متحدثة عربية',
          'أنا هنا لأدعمك بالعربي والإنجليزي. لستِ وحدكِ في هذه الرحلة.', false),
    ];

    return Column(children: [
      ...mentors.map((m) => Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: m.$2, shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5)),
            child: Center(child: Text(m.$1,
              style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                fontWeight: FontWeight.w500, color: m.$3))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.$4, style: AppText.bodySemibold),
              Text(m.$5, style: AppText.bodySemibold.copyWith(
                color: m.$3, fontSize: 11)),
              Text(m.$6, style: AppText.caption.copyWith(fontSize: 11)),
              const SizedBox(height: 6),
              Text(m.$7, style: AppText.bodySecondary, maxLines: 2,
                overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: m.$8 ? m.$3.withOpacity(0.12) : AppColors.primaryLight,
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: m.$8 ? m.$3.withOpacity(0.2) : AppColors.primaryMid,
                    width: 0.5),
                ),
                child: Text(m.$8 ? 'Message Lena → Free' : 'Connect → Free',
                  style: AppText.caption.copyWith(
                    color: m.$8 ? m.$3 : AppColors.primary,
                    fontWeight: FontWeight.w500, fontSize: 11)),
              ),
            ],
          )),
        ]),
      )),
      const SizedBox(height: 24),
    ]);
  }

  Widget _buildCoaches() {
    final coaches = [
      ('DA', AppColors.primaryLight, AppColors.primary,
          'Dr. Amira Hassan', 'Clinical Psychologist · Dubai',
          'Specialises in cancer-related anxiety, grief, and adjustment.',
          '✓ Verified professional'),
      ('NR', AppColors.tealLight, AppColors.teal,
          'Nour R.', 'Oncology Dietitian · Abu Dhabi',
          'Helping patients eat and recover well during chemotherapy.',
          '✓ Verified professional'),
    ];

    return Column(children: [
      ...coaches.map((c) => Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: c.$2, shape: BoxShape.circle),
              child: Center(child: Text(c.$1,
                style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                  fontWeight: FontWeight.w500, color: c.$3))),
            ),
            const SizedBox(width: 9),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.$4, style: AppText.bodySemibold),
                Text(c.$5, style: AppText.caption),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.blue.withOpacity(0.18), width: 0.5),
                  ),
                  child: Text(c.$7,
                    style: AppText.caption.copyWith(
                      color: AppColors.blue, fontSize: 9, fontWeight: FontWeight.w500)),
                ),
              ],
            )),
          ]),
          const SizedBox(height: 9),
          Text(c.$6, style: AppText.bodySecondary),
          const SizedBox(height: 9),
          Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: c.$3.withOpacity(0.10),
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: c.$3.withOpacity(0.18), width: 0.5),
              ),
              child: Center(child: Text('Book free consult',
                style: AppText.caption.copyWith(
                  color: c.$3, fontWeight: FontWeight.w500))),
            )),
            const SizedBox(width: 6),
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Center(child: Text('View profile',
                style: AppText.caption.copyWith(
                  color: AppColors.text2, fontWeight: FontWeight.w500))),
            )),
          ]),
        ]),
      )),
      const SizedBox(height: 24),
    ]);
  }

  Widget _buildStories() {
    return Column(children: [
      Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: const BorderRadius.only(
                topLeft: AppRadius.md, topRight: AppRadius.md)),
            child: const Center(child: Text('🌟', style: TextStyle(fontSize: 22))),
          ),
          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: AppRadius.fullBR),
                  child: Text('Featured',
                    style: AppText.caption.copyWith(
                      color: AppColors.gold, fontWeight: FontWeight.w600,
                      fontSize: 10)),
                ),
                Text('6 min read', style: AppText.caption.copyWith(fontSize: 10)),
              ]),
              const SizedBox(height: 5),
              Text('I finished chemo. Here\'s what no one told me.',
                style: AppText.bodySemibold.copyWith(fontSize: 13)),
              const SizedBox(height: 4),
              Text('After 12 sessions, I thought the hard part was over. I was wrong — and I was so grateful.',
                style: AppText.bodySecondary, maxLines: 2,
                overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.goldLight, shape: BoxShape.circle),
                  child: Center(child: Text('SR',
                    style: AppText.caption.copyWith(
                      fontSize: 9, fontWeight: FontWeight.w500,
                      color: AppColors.gold))),
                ),
                const SizedBox(width: 7),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Sara R.', style: AppText.caption),
                  Text('Breast cancer survivor · 2 years free',
                    style: AppText.caption.copyWith(fontSize: 9)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 0.5),
                  ),
                  child: Text('Read →',
                    style: AppText.caption.copyWith(
                      color: AppColors.gold, fontWeight: FontWeight.w500)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 24),
    ]);
  }
}
