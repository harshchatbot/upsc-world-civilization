import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/era_node.dart';
import '../models/quiz_question.dart';
import '../models/scene_step.dart';

final Provider<ContentRepository> contentRepositoryProvider =
    Provider<ContentRepository>((Ref ref) {
      return ContentRepository(FirebaseFirestore.instance);
    });

class ContentRepository {
  ContentRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<EraNode>> fetchNodes() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('nodes')
          .orderBy('order')
          .get();
      if (snap.docs.isEmpty) return _fallbackNodes;
      return snap.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                EraNode.fromMap(doc.id, doc.data()),
          )
          .toList();
    } catch (_) {
      return _fallbackNodes;
    }
  }

  Future<SceneContent> fetchSceneByNodeId(String nodeId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('scenes')
          .where('nodeId', isEqualTo: nodeId)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final QueryDocumentSnapshot<Map<String, dynamic>> doc = snap.docs.first;
        return SceneContent.fromMap(doc.id, doc.data());
      }
    } catch (_) {
      // Fallback below.
    }
    return _fallbackScenes.firstWhere((SceneContent s) => s.nodeId == nodeId);
  }

  Future<List<QuizQuestion>> fetchQuizByNodeId(String nodeId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('quizzes')
          .where('nodeId', isEqualTo: nodeId)
          .get();
      if (snap.docs.isNotEmpty) {
        return snap.docs
            .map(
              (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                  QuizQuestion.fromMap(doc.id, doc.data()),
            )
            .toList();
      }
    } catch (_) {
      // Fallback below.
    }
    return _fallbackQuiz
        .where((QuizQuestion q) => q.nodeId == nodeId)
        .toList(growable: false);
  }

  static const List<EraNode> _fallbackNodes = <EraNode>[
    EraNode(
      id: 'stone_age',
      title: 'Stone Age',
      order: 0,
      dx: 140,
      dy: 520,
      sceneId: 'stone_age_scene',
    ),
    EraNode(
      id: 'indus_valley',
      title: 'Indus Valley',
      order: 1,
      dx: 360,
      dy: 410,
      sceneId: 'indus_valley_scene',
    ),
    EraNode(
      id: 'vedic_age',
      title: 'Vedic Age',
      order: 2,
      dx: 620,
      dy: 340,
      sceneId: 'vedic_age_scene',
    ),
    EraNode(
      id: 'mauryan_era',
      title: 'Mauryan Era',
      order: 3,
      dx: 900,
      dy: 280,
      sceneId: 'mauryan_era_scene',
    ),
    EraNode(
      id: 'gupta_period',
      title: 'Gupta Period',
      order: 4,
      dx: 1160,
      dy: 220,
      sceneId: 'gupta_period_scene',
    ),
  ];

  static const List<SceneContent> _fallbackScenes = <SceneContent>[
    SceneContent(
      id: 'stone_age_scene',
      nodeId: 'stone_age',
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
      dialogues: <String>[
        'You step into a river valley where hunter-gatherer groups track seasonal migrations.',
        'Stone tools, fire control, and cooperative camps become the key survival technologies.',
        'This era sets the foundation of human adaptation and early social coordination.',
      ],
    ),
    SceneContent(
      id: 'indus_valley_scene',
      nodeId: 'indus_valley',
      imageUrl:
          'https://images.unsplash.com/photo-1539650116574-75c0c6d73f78?auto=format&fit=crop&w=1200&q=80',
      dialogues: <String>[
        'Urban planning emerges at Harappa and Mohenjo-daro with standardized bricks and drains.',
        'Trade networks connect the civilization to Mesopotamia through seals and ports.',
        'The script remains undeciphered, but civic planning reveals advanced administration.',
      ],
    ),
    SceneContent(
      id: 'vedic_age_scene',
      nodeId: 'vedic_age',
      imageUrl:
          'https://images.unsplash.com/photo-1577083552431-6e5fd01988f1?auto=format&fit=crop&w=1200&q=80',
      dialogues: <String>[
        'Pastoral communities compose Vedic hymns and shape ritual-centered social life.',
        'Assemblies, clan structures, and evolving agriculture transform the Gangetic region.',
        'Late Vedic society shows sharper hierarchy and the rise of territorial polities.',
      ],
    ),
    SceneContent(
      id: 'mauryan_era_scene',
      nodeId: 'mauryan_era',
      imageUrl:
          'https://images.unsplash.com/photo-1561361513-2d000a50f0dc?auto=format&fit=crop&w=1200&q=80',
      dialogues: <String>[
        'Chandragupta builds one of South Asia’s first large centralized empires.',
        'Kautilya’s statecraft emphasizes administration, espionage, and fiscal systems.',
        'Ashoka’s inscriptions mark a shift toward dhamma and ethical kingship after Kalinga.',
      ],
    ),
    SceneContent(
      id: 'gupta_period_scene',
      nodeId: 'gupta_period',
      imageUrl:
          'https://images.unsplash.com/photo-1524492514790-831f5b7a47f0?auto=format&fit=crop&w=1200&q=80',
      dialogues: <String>[
        'The Gupta age sees major advances in mathematics, astronomy, and classical literature.',
        'Temple architecture and Sanskrit culture gain broad prestige across regions.',
        'Decentralized governance coexists with strong cultural integration.',
      ],
    ),
  ];

  static const List<QuizQuestion> _fallbackQuiz = <QuizQuestion>[
    QuizQuestion(
      id: 'stone_1',
      nodeId: 'stone_age',
      question: 'Which innovation most transformed early human diets?',
      options: <String>[
        'Wheel making',
        'Control of fire',
        'Bronze casting',
        'Coinage',
      ],
      correctIndex: 1,
      explanation:
          'Fire enabled cooking, which improved digestion and nutrition.',
    ),
    QuizQuestion(
      id: 'stone_2',
      nodeId: 'stone_age',
      question: 'Stone Age communities were primarily:',
      options: <String>[
        'Industrial laborers',
        'Hunter-gatherers',
        'Temple priests',
        'Imperial tax agents',
      ],
      correctIndex: 1,
      explanation:
          'Most groups relied on hunting, foraging, and seasonal mobility.',
    ),
    QuizQuestion(
      id: 'stone_3',
      nodeId: 'stone_age',
      question: 'The Paleolithic period is associated with:',
      options: <String>[
        'Polished iron tools',
        'Microlithic blades only',
        'Old stone tools',
        'Large temple complexes',
      ],
      correctIndex: 2,
      explanation:
          'Paleolithic means “Old Stone Age,” known for early chipped tools.',
    ),
    QuizQuestion(
      id: 'indus_1',
      nodeId: 'indus_valley',
      question: 'A key feature of Indus cities was:',
      options: <String>[
        'Grid planning',
        'Royal pyramids',
        'Silk roads',
        'Paper currency',
      ],
      correctIndex: 0,
      explanation:
          'Indus settlements were planned with streets in a grid pattern.',
    ),
    QuizQuestion(
      id: 'indus_2',
      nodeId: 'indus_valley',
      question: 'Indus Valley script is currently:',
      options: <String>[
        'Fully translated',
        'Partially translated',
        'Undeciphered',
        'Lost by war',
      ],
      correctIndex: 2,
      explanation: 'No consensus decipherment exists for the script.',
    ),
    QuizQuestion(
      id: 'indus_3',
      nodeId: 'indus_valley',
      question: 'Which site is associated with dockyard evidence?',
      options: <String>['Lothal', 'Taxila', 'Sarnath', 'Nalanda'],
      correctIndex: 0,
      explanation: 'Lothal is known for probable dockyard architecture.',
    ),
    QuizQuestion(
      id: 'vedic_1',
      nodeId: 'vedic_age',
      question: 'Early Vedic economy was mainly:',
      options: <String>[
        'Marine trade based',
        'Pastoral',
        'Factory based',
        'Plantation based',
      ],
      correctIndex: 1,
      explanation: 'Cattle and pastoral livelihoods dominated the early phase.',
    ),
    QuizQuestion(
      id: 'vedic_2',
      nodeId: 'vedic_age',
      question: 'Which text corpus belongs to the Vedic period?',
      options: <String>[
        'Vedas',
        'Puranas only',
        'Arthashastra',
        'Ain-i-Akbari',
      ],
      correctIndex: 0,
      explanation: 'The Vedas are foundational texts from this period.',
    ),
    QuizQuestion(
      id: 'vedic_3',
      nodeId: 'vedic_age',
      question: 'Later Vedic changes included:',
      options: <String>[
        'Rise of territorial kingdoms',
        'Complete urban collapse',
        'European colonization',
        'Printing technology',
      ],
      correctIndex: 0,
      explanation:
          'Janapadas and larger territorial structures became more prominent.',
    ),
    QuizQuestion(
      id: 'mauryan_1',
      nodeId: 'mauryan_era',
      question: 'Who authored Arthashastra (traditionally attributed)?',
      options: <String>['Kalidasa', 'Kautilya', 'Banabhatta', 'Panini'],
      correctIndex: 1,
      explanation:
          'Kautilya (Chanakya) is traditionally linked to Arthashastra.',
    ),
    QuizQuestion(
      id: 'mauryan_2',
      nodeId: 'mauryan_era',
      question: 'Ashoka’s inscriptions were largely about:',
      options: <String>[
        'Naval campaigns',
        'Dhamma',
        'Minting policy only',
        'Land grants only',
      ],
      correctIndex: 1,
      explanation: 'They emphasize ethical governance and dhamma.',
    ),
    QuizQuestion(
      id: 'mauryan_3',
      nodeId: 'mauryan_era',
      question: 'Mauryan capital was:',
      options: <String>['Pataliputra', 'Ujjain', 'Kanchi', 'Madurai'],
      correctIndex: 0,
      explanation: 'Pataliputra was the imperial center.',
    ),
    QuizQuestion(
      id: 'gupta_1',
      nodeId: 'gupta_period',
      question: 'The Gupta period is often noted for advances in:',
      options: <String>[
        'Gunpowder',
        'Calculus in Europe',
        'Mathematics and astronomy',
        'Steam engines',
      ],
      correctIndex: 2,
      explanation: 'Important achievements include work in math and astronomy.',
    ),
    QuizQuestion(
      id: 'gupta_2',
      nodeId: 'gupta_period',
      question: 'Which scholar is linked to Gupta-era science?',
      options: <String>['Aryabhata', 'Megasthenes', 'Al-Biruni', 'Ibn Battuta'],
      correctIndex: 0,
      explanation: 'Aryabhata is a key mathematician-astronomer of the period.',
    ),
    QuizQuestion(
      id: 'gupta_3',
      nodeId: 'gupta_period',
      question:
          'Classical Sanskrit literature flourished significantly during:',
      options: <String>[
        'Gupta period',
        'Neolithic age',
        'Delhi Sultanate only',
        'Colonial period',
      ],
      correctIndex: 0,
      explanation:
          'The Gupta age saw major literary and cultural contributions.',
    ),
  ];
}
