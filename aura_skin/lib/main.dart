import 'package:flutter/material.dart';
import 'db_helper.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AuraSkinApp());
}

class AuraSkinApp extends StatelessWidget {
  const AuraSkinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aura Skin',
      theme: ThemeData(
        primaryColor: const Color(0xFF8E97FD),
        fontFamily: 'Roboto', // Modern bir duruş için varsayılan fontu düzenliyoruz
      ),
      home: const AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int _seciliSayfaIndex = 0;

  final List<Widget> _sayfalar = [
    const RutinSayfasi(),
    const Center(child: Text("Keşfet", style: TextStyle(fontSize: 20))),
    const Center(child: Text("Manifest", style: TextStyle(fontSize: 20))),
    const Center(child: Text("Profil", style: TextStyle(fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sayfalar[_seciliSayfaIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          currentIndex: _seciliSayfaIndex,
          onTap: (index) => setState(() => _seciliSayfaIndex = index),
          selectedItemColor: const Color(0xFF8E97FD),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Ana Sayfa'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Rutin'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Keşfet'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class RutinSayfasi extends StatefulWidget {
  const RutinSayfasi({super.key});

  @override
  State<RutinSayfasi> createState() => _RutinSayfasiState();
}

class _RutinSayfasiState extends State<RutinSayfasi> {
  int tamamlananGorev = 0;
  int toplamGorev = 4;
  String seciliCinsiyet = 'erkek'; 
  bool yukleniyor = true;

  // Arayüzdeki şık liste için görevlerimizi tanımlıyoruz
  List<Map<String, dynamic>> gorevler = [
    {"ad": "Günlük Cilt Temizliği", "ikon": Icons.wb_sunny_outlined, "yapildi": false},
    {"ad": "Nemlendirici", "ikon": Icons.water_drop_outlined, "yapildi": false},
    {"ad": "Güneş Kremi", "ikon": Icons.shield_outlined, "yapildi": false},
    {"ad": "(İsteğe Bağlı) Buz Uygulaması", "ikon": Icons.ac_unit, "yapildi": false},
  ];

  @override
  void initState() {
    super.initState();
    _veritabanindanVeriCek();
  }

  Future<void> _veritabanindanVeriCek() async {
    final veri = await DBHelper.instance.getRutinVerisi();
    if (veri != null) {
      setState(() {
        tamamlananGorev = veri['tamamlanan_gorev'];
        toplamGorev = veri['toplam_gorev'];
        
        // Veritabanından gelen sayıya göre kutucukları işaretle
        for (int i = 0; i < gorevler.length; i++) {
          gorevler[i]['yapildi'] = i < tamamlananGorev;
        }
        yukleniyor = false;
      });
    }
  }

  // Bir göreve tıklandığında çalışacak fonksiyon
  Future<void> _gorevTetikle(int index, bool? deger) async {
    setState(() {
      gorevler[index]['yapildi'] = deger ?? false;
      // Kaç tane 'true' (yapıldı) olduğunu say
      tamamlananGorev = gorevler.where((g) => g['yapildi'] == true).length;
    });
    // Yeni sayıyı SQLite'a kaydet
    await DBHelper.instance.goreviGuncelle(tamamlananGorev);
  }

  @override
  Widget build(BuildContext context) {
    if (yukleniyor) return const Center(child: CircularProgressIndicator(color: Color(0xFF8E97FD)));

    double basariOrani = tamamlananGorev / toplamGorev;
    String gosterilecekResim = basariOrani >= 0.5 
        ? 'assets/images/${seciliCinsiyet}_mutlu.jpg' 
        : 'assets/images/${seciliCinsiyet}_uzgun.png';

    return Container(
      // Referans görselindeki o harika soft arka plan geçişi (Gradient)
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F0FA), Colors.white],
          stops: [0.0, 0.4], // Gradient'in nerede beyaza döneceği
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Şık Başlık
                const Text(
                  "Cilt Yolculuğun:\nGünlük Rutin",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2, color: Color(0xFF2D3142)),
                ),
                const SizedBox(height: 30),
                
                // Avatar (Arkasına hafif bir parlama glow efekti verdik)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E97FD).withOpacity(0.2),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(gosterilecekResim, width: 220, height: 220, fit: BoxFit.contain),
                ),
                
                const SizedBox(height: 40),

                // Görev Listesi (Checkboxes)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: List.generate(gorevler.length, (index) {
                      final gorev = gorevler[index];
                      return CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Row(
                          children: [
                            Icon(gorev['ikon'], color: const Color(0xFF8E97FD), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                gorev['ad'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: gorev['yapildi'] ? Colors.grey : const Color(0xFF2D3142),
                                  decoration: gorev['yapildi'] ? TextDecoration.lineThrough : null, // Yapılınca üstünü çiz
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: gorev['yapildi'],
                        onChanged: (bool? value) => _gorevTetikle(index, value),
                        activeColor: const Color(0xFF8E97FD),
                        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        controlAffinity: ListTileControlAffinity.leading, // Kutucuk solda dursun
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 30),

                // Şık İlerleme Çubuğu (Progress Bar)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Rutin İlerlemesi: %${(basariOrani * 100).toInt()}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D3142)),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: basariOrani,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8E97FD)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}