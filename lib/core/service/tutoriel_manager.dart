import 'package:shared_preferences/shared_preferences.dart';

class LinkedTutorialManager {
  static const String _shareButtonTutorialKey = 'share_button_tutorial_seen';
  static const String _quickActionsTutorialKey = 'quick_actions_sequential_tutorial_seen';
  static const String _linkedTutorialsCompletedKey = 'linked_tutorials_completed';

  static LinkedTutorialManager? _instance;
  static LinkedTutorialManager get instance => _instance ??= LinkedTutorialManager._();
  LinkedTutorialManager._();

  // Vérifier si le tutoriel Share Button doit être affiché
  Future<bool> shouldShowShareButtonTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final shareButtonSeen = prefs.getBool(_shareButtonTutorialKey) ?? false;
    final linkedCompleted = prefs.getBool(_linkedTutorialsCompletedKey) ?? false;
    return !shareButtonSeen && !linkedCompleted;
  }

  // Vérifier si le tutoriel Quick Actions doit être affiché
  Future<bool> shouldShowQuickActionsTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final shareButtonSeen = prefs.getBool(_shareButtonTutorialKey) ?? false;
    final quickActionsSeen = prefs.getBool(_quickActionsTutorialKey) ?? false;
    final linkedCompleted = prefs.getBool(_linkedTutorialsCompletedKey) ?? false;
    
    // Quick Actions ne se montre que si Share Button est terminé
    return shareButtonSeen && !quickActionsSeen && !linkedCompleted;
  }

  // Marquer Share Button comme vu
  Future<void> markShareButtonTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shareButtonTutorialKey, true);
  }

  // Marquer Quick Actions comme vu et terminer la séquence liée
  Future<void> markQuickActionsTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quickActionsTutorialKey, true);
    await prefs.setBool(_linkedTutorialsCompletedKey, true);
  }

  // Marquer tous les tutoriels liés comme vus (en cas d'ignore)
  Future<void> markAllLinkedTutorialsAsSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shareButtonTutorialKey, true);
    await prefs.setBool(_quickActionsTutorialKey, true);
    await prefs.setBool(_linkedTutorialsCompletedKey, true);
  }

  // Vérifier si tous les tutoriels liés sont terminés
  Future<bool> areLinkedTutorialsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_linkedTutorialsCompletedKey) ?? false;
  }
}