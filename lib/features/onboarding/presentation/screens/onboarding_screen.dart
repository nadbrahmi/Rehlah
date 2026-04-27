import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_session.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  int _whoIndex = 0;
  final _nameController = TextEditingController();
  int _typeIndex = 0;
  int _phaseIndex = 2;
  final Set<int> _notifSelected = {0, 1};

  final _cancerTypes = ['Breast','Lung','Colorectal','Leukemia','Lymphoma','Other'];
  final _cancerEmojis = ['🎀','🫁','🫀','🩸','💜','✦'];
  final _phases = [
    'Just diagnosed','Awaiting treatment plan','In chemotherapy',
    'In radiotherapy','Post-surgery recovery','Monitoring / surveillance'];

  String get _firstName {
    final t = _nameController.text.trim();
    return t.isEmpty ? 'there' : t;
  }

  void _next() {
    if (_page == 2) UserSession().name = _firstName;
    if (_page == 3) UserSession().cancerType = _cancerTypes[_typeIndex];
    if (_page == 4) UserSession().treatmentPhase = _phases[_phaseIndex];
    if (_page < 6) {
      final next = _page + 1;
      setState(() => _page = next);
      _pageController.animateToPage(next,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.go('/');
    }
  }

  void _back() {
    if (_page > 0) {
      final prev = _page - 1;
      setState(() => _page = prev);
      _pageController.animateToPage(prev,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        Positioned(top: -70, right: -50, child: Container(width: 220, height: 220,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [AppColors.primary.withOpacity(0.13), Colors.transparent])))),
        Positioned(bottom: 100, left: -30, child: Container(width: 160, height: 160,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [AppColors.teal.withOpacity(0.08), Colors.transparent])))),
        SafeArea(child: Column(children: [
          if (_page > 0 && _page < 6) _dots(),
          Expanded(child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [_welcome(),_who(),_name(),_type(),_phase(),_notifs(),_celebration()],
          )),
        ])),
      ]),
    );
  }

  Widget _dots() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final p = i + 1;
        final done = _page > p; final active = _page == p;
        return AnimatedContainer(duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: active ? 20 : (done ? 12 : 6), height: 4,
          decoration: BoxDecoration(
            color: done ? AppColors.teal : active ? AppColors.primary : AppColors.primary.withOpacity(0.13),
            borderRadius: BorderRadius.circular(10)));
      })),
  );

  // PAGE 0 WELCOME
  Widget _welcome() => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24,20,24,24),
    child: Column(children: [
      const SizedBox(height:20),
      Container(width:76,height:76,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: const LinearGradient(begin: Alignment(-0.6,-0.8), end: Alignment(1,1),
            colors: [Color(0xFFDDD4F5),Color(0xFFCCC0EC),Color(0xFFE8D4E0)]),
          border: Border.all(color: Colors.white.withOpacity(0.8), width:0.5),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.22), blurRadius:28, offset: const Offset(0,10))]),
        child: const Icon(Icons.auto_awesome_rounded, size:28, color: AppColors.primary)),
      const SizedBox(height:16),
      const Text('Rehlah', style: TextStyle(fontFamily:'Inter',fontSize:28,fontWeight:FontWeight.w300,color:AppColors.text1,letterSpacing:0.02)),
      const SizedBox(height:3),
      const Text('رحلة · Your journey', style: TextStyle(fontFamily:'Inter',fontSize:15,color:AppColors.text2,fontWeight:FontWeight.w300)),
      const SizedBox(height:8),
      const Text('A companion for every step\nof your cancer journey', textAlign: TextAlign.center,
        style: TextStyle(fontFamily:'Inter',fontSize:13,color:AppColors.text3,fontWeight:FontWeight.w300,height:1.6)),
      const SizedBox(height:28),
      _fpill(Icons.auto_awesome_rounded, AppColors.primaryLight, AppColors.primary,'AI companion','that understands oncology'),
      const SizedBox(height:8),
      _fpill(Icons.check_circle_outline_rounded, AppColors.tealLight, AppColors.teal,'Track','symptoms, meds & appointments'),
      const SizedBox(height:8),
      _fpill(Icons.people_outline_rounded, AppColors.peachLight, AppColors.peach,'Community','of patients & survivors'),
      const SizedBox(height:24),
      _ghost('Explore with sample data', _next),
      const SizedBox(height:10),
      const Text('🔒 Your data stays yours. We never sell your health information.',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily:'Inter',fontSize:11,color:AppColors.text3,fontWeight:FontWeight.w300,height:1.6)),
      const SizedBox(height:16),
      _btn('Get started', _next),
    ]),
  );

  Widget _fpill(IconData icon, Color bg, Color color, String bold, String rest) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal:14,vertical:10),
      decoration: BoxDecoration(color:AppColors.surface,borderRadius:BorderRadius.circular(100),
        border: Border.all(color:AppColors.border,width:0.5)),
      child: Row(children:[
        Container(width:26,height:26,decoration:BoxDecoration(color:bg,shape:BoxShape.circle),
          child:Icon(icon,size:13,color:color)),
        const SizedBox(width:10),
        RichText(text: TextSpan(
          style: const TextStyle(fontFamily:'Inter',fontSize:13,color:AppColors.text2,fontWeight:FontWeight.w300),
          children:[TextSpan(text:bold,style:const TextStyle(fontWeight:FontWeight.w500,color:AppColors.text1)),TextSpan(text:' $rest')])),
      ]),
    );

  // PAGE 1 WHO
  Widget _who() {
    final opts = [
      ('🧑‍⚕️',AppColors.primaryLight,"I'm a patient",'Diagnosed with or undergoing treatment'),
      ('🤝',AppColors.peachLight,"I'm a caregiver",'Supporting a loved one through their journey'),
      ('🌟',AppColors.tealLight,"I'm a survivor",'Cancer-free and in the monitoring phase'),
    ];
    return _scaffold('Step 1 of 5','Who is\n','using Rehlah?',
      'This helps us personalise your experience.',
      Column(children: opts.asMap().entries.map((e){
        final sel = _whoIndex == e.key;
        return GestureDetector(onTap:()=>setState(()=>_whoIndex=e.key),
          child: AnimatedContainer(duration:const Duration(milliseconds:150),
            margin:const EdgeInsets.only(bottom:8), padding:const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: sel?AppColors.primary.withOpacity(0.06):AppColors.surface,
              borderRadius:BorderRadius.circular(14),
              border:Border.all(color:sel?AppColors.primaryMid:AppColors.border,width:0.5)),
            child: Row(children:[
              Container(width:36,height:36,decoration:BoxDecoration(color:e.value.$2,borderRadius:BorderRadius.circular(11)),
                child:Center(child:Text(e.value.$1,style:const TextStyle(fontSize:18)))),
              const SizedBox(width:10),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(e.value.$3,style:TextStyle(fontFamily:'Inter',fontSize:13,fontWeight:FontWeight.w500,color:sel?AppColors.primary:AppColors.text1)),
                Text(e.value.$4,style:const TextStyle(fontFamily:'Inter',fontSize:11,color:AppColors.text2,fontWeight:FontWeight.w300)),
              ])),
              Container(width:18,height:18,
                decoration:BoxDecoration(shape:BoxShape.circle,
                  color:sel?AppColors.primary:Colors.transparent,
                  border:Border.all(color:sel?AppColors.primary:AppColors.border,width:1.5)),
                child:sel?const Icon(Icons.check_rounded,size:10,color:Colors.white):null),
            ])));
      }).toList()),
      _next,_back);
  }

  // PAGE 2 NAME
  Widget _name() => _scaffold('Step 2 of 5','What should\nwe ','call you?',
    "First name only is fine. You're in control.",
    Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text('YOUR NAME',style:TextStyle(fontFamily:'Inter',fontSize:11,fontWeight:FontWeight.w600,letterSpacing:0.07,color:AppColors.text3)),
      const SizedBox(height:8),
      TextField(
        controller:_nameController, textCapitalization:TextCapitalization.words,
        onChanged:(_)=>setState((){}),
        style:const TextStyle(fontFamily:'Inter',fontSize:15,color:AppColors.text1),
        decoration:InputDecoration(
          hintText:'First name', hintStyle:const TextStyle(color:AppColors.text3),
          filled:true, fillColor:AppColors.surface,
          border:OutlineInputBorder(borderRadius:BorderRadius.circular(13),borderSide:const BorderSide(color:AppColors.border,width:0.5)),
          enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(13),borderSide:const BorderSide(color:AppColors.border,width:0.5)),
          focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(13),borderSide:BorderSide(color:AppColors.primaryMid,width:1)))),
      const SizedBox(height:8),
      const Text('No last name or email needed right now.',style:TextStyle(fontFamily:'Inter',fontSize:11,color:AppColors.text3,fontWeight:FontWeight.w300)),
      const SizedBox(height:14),
      Container(padding:const EdgeInsets.all(11),
        decoration:BoxDecoration(color:AppColors.teal.withOpacity(0.05),borderRadius:BorderRadius.circular(11),
          border:Border.all(color:AppColors.teal.withOpacity(0.18),width:0.5)),
        child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('🔒',style:TextStyle(fontSize:14)),
          const SizedBox(width:8),
          const Expanded(child:Text('Your name is only used within the app. We never share it.',
            style:TextStyle(fontFamily:'Inter',fontSize:11,color:AppColors.teal,fontWeight:FontWeight.w300,height:1.5))),
        ])),
    ]),
    _next,_back);

  // PAGE 3 CANCER TYPE
  Widget _type() => _scaffold('Step 3 of 5','What type of\n','cancer?',
    'Helps us surface the most relevant content.',
    Column(children:[
      GridView.count(crossAxisCount:2,shrinkWrap:true,
        physics:const NeverScrollableScrollPhysics(),
        crossAxisSpacing:8,mainAxisSpacing:8,childAspectRatio:2.2,
        children:List.generate(_cancerTypes.length,(i){
          final sel = _typeIndex==i;
          return GestureDetector(onTap:()=>setState(()=>_typeIndex=i),
            child:AnimatedContainer(duration:const Duration(milliseconds:150),
              decoration:BoxDecoration(
                color:sel?AppColors.primary.withOpacity(0.07):AppColors.surface,
                borderRadius:BorderRadius.circular(13),
                border:Border.all(color:sel?AppColors.primaryMid:AppColors.border,width:0.5)),
              child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
                Text(_cancerEmojis[i],style:const TextStyle(fontSize:20)),
                const SizedBox(width:8),
                Text(_cancerTypes[i],style:TextStyle(fontFamily:'Inter',fontSize:13,fontWeight:FontWeight.w500,color:sel?AppColors.primary:AppColors.text2)),
              ])));
        })),
      const SizedBox(height:10),
      const Text("Don't see yours? Choose Other — you can specify later.",
        textAlign:TextAlign.center,
        style:TextStyle(fontFamily:'Inter',fontSize:11,color:AppColors.text3,fontWeight:FontWeight.w300)),
    ]),
    _next,_back);

  // PAGE 4 PHASE
  Widget _phase() => _scaffold('Step 4 of 5','Where are you\nin your ','journey?',
    "There's no wrong answer.",
    Column(children:List.generate(_phases.length,(i){
      final sel = _phaseIndex==i;
      return GestureDetector(onTap:()=>setState(()=>_phaseIndex=i),
        child:AnimatedContainer(duration:const Duration(milliseconds:150),
          margin:const EdgeInsets.only(bottom:7),
          padding:const EdgeInsets.symmetric(horizontal:16,vertical:11),
          decoration:BoxDecoration(
            color:sel?AppColors.primary.withOpacity(0.07):AppColors.surface,
            borderRadius:BorderRadius.circular(100),
            border:Border.all(color:sel?AppColors.primaryMid:AppColors.border,width:0.5)),
          child:Row(children:[
            Container(width:7,height:7,decoration:BoxDecoration(shape:BoxShape.circle,color:sel?AppColors.primary:AppColors.border)),
            const SizedBox(width:10),
            Text(_phases[i],style:TextStyle(fontFamily:'Inter',fontSize:13,fontWeight:sel?FontWeight.w500:FontWeight.w400,color:sel?AppColors.primary:AppColors.text2)),
            if(sel)...[const Spacer(),Text('✓',style:TextStyle(color:AppColors.primary,fontSize:14))],
          ])));
    })),
    _next,_back,showSkip:true,skipLabel:'Prefer not to say');

  // PAGE 5 NOTIFICATIONS
  Widget _notifs() {
    final n = _firstName;
    final items = [
      (Icons.notifications_outlined,AppColors.primaryLight,AppColors.primary,'Daily check-in reminder','A gentle nudge each morning'),
      (Icons.medication_outlined,AppColors.tealLight,AppColors.teal,'Medication reminders','Never miss a dose'),
      (Icons.calendar_month_outlined,AppColors.peachLight,AppColors.peach,'Appointment alerts','Reminders 24 hours before'),
    ];
    return _scaffold('Step 5 of 5','One last\nthing, ',n,'Gentle reminders help you stay consistent.',
      Column(children:[
        ...items.asMap().entries.map((e){
          final sel=_notifSelected.contains(e.key);
          return GestureDetector(onTap:()=>setState((){if(sel)_notifSelected.remove(e.key);else _notifSelected.add(e.key);}),
            child:AnimatedContainer(duration:const Duration(milliseconds:150),
              margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(13),
              decoration:BoxDecoration(color:sel?AppColors.primary.withOpacity(0.06):AppColors.surface,borderRadius:BorderRadius.circular(14),
                border:Border.all(color:sel?AppColors.primaryMid:AppColors.border,width:0.5)),
              child:Row(children:[
                Container(width:36,height:36,decoration:BoxDecoration(color:e.value.$2,borderRadius:BorderRadius.circular(11)),
                  child:Icon(e.value.$1,size:17,color:e.value.$3)),
                const SizedBox(width:10),
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text(e.value.$4,style:TextStyle(fontFamily:'Inter',fontSize:13,fontWeight:FontWeight.w500,color:sel?AppColors.primary:AppColors.text1)),
                  Text(e.value.$5,style:const TextStyle(fontFamily:'Inter',fontSize:11,color:AppColors.text2,fontWeight:FontWeight.w300)),
                ])),
                Container(width:18,height:18,decoration:BoxDecoration(shape:BoxShape.circle,
                  color:sel?AppColors.primary:Colors.transparent,border:Border.all(color:sel?AppColors.primary:AppColors.border,width:1.5)),
                  child:sel?const Icon(Icons.check_rounded,size:10,color:Colors.white):null),
              ])));
        }),
        const SizedBox(height:8),
        const Text('You can change these anytime in Settings.',textAlign:TextAlign.center,
          style:TextStyle(fontFamily:'Inter',fontSize:11,color:AppColors.text3,fontWeight:FontWeight.w300)),
      ]),
      _next,_back,showSkip:true,skipLabel:'Maybe later',primaryLabel:'Enable notifications');
  }

  // PAGE 6 CELEBRATION
  Widget _celebration() {
    final name = UserSession().displayName;
    final type = _cancerTypes[_typeIndex];
    return Column(children:[
      const SizedBox(height:60),
      Container(width:80,height:80,
        decoration:BoxDecoration(shape:BoxShape.circle,
          gradient:RadialGradient(colors:[AppColors.teal.withOpacity(0.18),AppColors.primary.withOpacity(0.10)]),
          border:Border.all(color:AppColors.teal.withOpacity(0.28),width:1.5),
          boxShadow:[BoxShadow(color:AppColors.teal.withOpacity(0.12),blurRadius:28)]),
        child:const Center(child:Text('🌿',style:TextStyle(fontSize:30)))),
      const SizedBox(height:20),
      const Text('Your journey is ready,',style:TextStyle(fontFamily:'Inter',fontSize:15,fontWeight:FontWeight.w300,color:AppColors.text2)),
      const SizedBox(height:4),
      Text(name,style:const TextStyle(fontFamily:'Inter',fontSize:26,fontWeight:FontWeight.w700,color:AppColors.primary,letterSpacing:-0.5)),
      const SizedBox(height:14),
      Padding(padding:const EdgeInsets.symmetric(horizontal:40),
        child:Text('Everything is personalised for your $type journey. We\'re here every step of the way.',
          textAlign:TextAlign.center,
          style:const TextStyle(fontFamily:'Inter',fontSize:14,fontWeight:FontWeight.w300,color:AppColors.text2,height:1.7))),
      const SizedBox(height:28),
      Padding(padding:const EdgeInsets.symmetric(horizontal:32),
        child:Row(children:[
          _cs('12','Weeks planned'),const SizedBox(width:8),
          _cs('3','Meds to add'),const SizedBox(width:8),
          _cs('💜','Community'),
        ])),
      const Spacer(),
      Padding(padding:const EdgeInsets.fromLTRB(24,0,24,32),
        child:GestureDetector(onTap:()=>context.go('/'),
          child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:14),
            decoration:BoxDecoration(
              gradient:const LinearGradient(colors:[Color(0xFF3DB87A),Color(0xFF2A9060)]),
              borderRadius:BorderRadius.circular(13),
              boxShadow:[BoxShadow(color:AppColors.teal.withOpacity(0.3),blurRadius:12,offset:const Offset(0,4))]),
            child:const Center(child:Text('Go to my dashboard',style:TextStyle(fontFamily:'Inter',fontSize:15,fontWeight:FontWeight.w500,color:Colors.white)))))),
    ]);
  }

  Widget _cs(String v,String l)=>Expanded(child:Container(
    padding:const EdgeInsets.symmetric(vertical:10),
    decoration:BoxDecoration(color:AppColors.surface,borderRadius:BorderRadius.circular(13),border:Border.all(color:AppColors.border,width:0.5)),
    child:Column(children:[
      Text(v,style:const TextStyle(fontFamily:'Inter',fontSize:16,fontWeight:FontWeight.w400,color:AppColors.text1)),
      const SizedBox(height:2),
      Text(l,textAlign:TextAlign.center,style:const TextStyle(fontFamily:'Inter',fontSize:9,color:AppColors.text3,letterSpacing:0.04)),
    ])));

  // SHARED SCAFFOLD
  Widget _scaffold(String step,String title,String bold,String sub,Widget body,
      VoidCallback onCont,VoidCallback onBack,{bool showSkip=false,String skipLabel='Skip',String primaryLabel='Continue'}) {
    return SingleChildScrollView(
      padding:const EdgeInsets.fromLTRB(20,8,20,24),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        GestureDetector(onTap:onBack,child:Row(children:[
          Icon(Icons.arrow_back_ios_new_rounded,size:15,color:AppColors.text2.withOpacity(0.4)),
          const SizedBox(width:4),
          Text('Back',style:TextStyle(fontFamily:'Inter',fontSize:12,color:AppColors.text2)),
        ])),
        const SizedBox(height:14),
        Text(step.toUpperCase(),style:const TextStyle(fontFamily:'Inter',fontSize:10,fontWeight:FontWeight.w600,letterSpacing:0.07,color:AppColors.text3)),
        const SizedBox(height:8),
        RichText(text:TextSpan(
          style:const TextStyle(fontFamily:'Inter',fontSize:22,fontWeight:FontWeight.w300,color:AppColors.text1,letterSpacing:-0.3,height:1.2),
          children:[TextSpan(text:title),TextSpan(text:bold,style:const TextStyle(fontWeight:FontWeight.w700))])),
        const SizedBox(height:5),
        Text(sub,style:const TextStyle(fontFamily:'Inter',fontSize:13,color:AppColors.text2,fontWeight:FontWeight.w300,height:1.6)),
        const SizedBox(height:18),
        body,
        const SizedBox(height:20),
        _btn(primaryLabel,onCont),
        if(showSkip)...[const SizedBox(height:8),_ghost(skipLabel,onCont)],
      ]));
  }

  Widget _btn(String l,VoidCallback t)=>GestureDetector(onTap:t,
    child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:14),
      decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(13),
        boxShadow:[BoxShadow(color:AppColors.primary.withOpacity(0.3),blurRadius:10,offset:const Offset(0,3))]),
      child:Center(child:Text(l,style:const TextStyle(fontFamily:'Inter',fontSize:15,fontWeight:FontWeight.w500,color:Colors.white)))));

  Widget _ghost(String l,VoidCallback t)=>GestureDetector(onTap:t,
    child:Container(width:double.infinity,padding:const EdgeInsets.symmetric(vertical:11),
      child:Center(child:Text(l,style:const TextStyle(fontFamily:'Inter',fontSize:13,color:AppColors.text3)))));
}
