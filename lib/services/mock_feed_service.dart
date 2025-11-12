import '../models/article.dart';

class MockFeedService {
  static final MockFeedService instance = MockFeedService._();
  MockFeedService._();

  final List<Article> _articles = [
    Article(
      id: '1',
      title: 'Quantum Computing Revolution',
      summary: 'Quantum computers are poised to revolutionize computing by solving problems that would take classical computers millennia. Recent breakthroughs in quantum error correction and qubit stability are bringing us closer to practical quantum advantage in fields like cryptography, drug discovery, and artificial intelligence.',
      imageUrl: 'https://picsum.photos/seed/quantum/800/1200',
      tags: ['Technology', 'Physics', 'Computing'],
      likeCount: 2453,
      commentCount: 342,
      saveCount: 892,
      category: 'Technology',
      categoryColor: '#4CAF50',
    ),
    Article(
      id: '2',
      title: 'Ancient Roman Architecture',
      summary: 'The architectural genius of Ancient Rome gave us the Colosseum, Pantheon, and revolutionary construction techniques like the arch and concrete. These innovations not only stood the test of time but influenced architectural design for millennia, shaping how we build cities even today.',
      imageUrl: 'https://picsum.photos/seed/rome/800/1200',
      tags: ['History', 'Architecture', 'Rome'],
      likeCount: 1876,
      commentCount: 234,
      saveCount: 567,
      category: 'History',
      categoryColor: '#FF9800',
    ),
    Article(
      id: '3',
      title: 'The Human Brain: Neuroscience Breakthrough',
      summary: 'Scientists have discovered new neural pathways that explain how memories are formed and retrieved. This groundbreaking research could lead to treatments for Alzheimer\'s, PTSD, and other neurological conditions, while deepening our understanding of consciousness itself.',
      imageUrl: 'https://picsum.photos/seed/brain/800/1200',
      tags: ['Science', 'Neuroscience', 'Medicine'],
      likeCount: 3421,
      commentCount: 521,
      saveCount: 1234,
      category: 'Science',
      categoryColor: '#2196F3',
    ),
    Article(
      id: '4',
      title: 'Climate Change and Ocean Currents',
      summary: 'New climate models reveal how melting ice caps are disrupting ocean currents that regulate global weather patterns. These changes could have profound effects on agriculture, marine ecosystems, and coastal communities worldwide, making immediate action more critical than ever.',
      imageUrl: 'https://picsum.photos/seed/ocean/800/1200',
      tags: ['Environment', 'Climate', 'Oceanography'],
      likeCount: 4567,
      commentCount: 892,
      saveCount: 1789,
      category: 'Environment',
      categoryColor: '#00BCD4',
    ),
    Article(
      id: '5',
      title: 'Renaissance Art Masters',
      summary: 'The Renaissance period produced artistic geniuses like Leonardo da Vinci, Michelangelo, and Raphael who transformed art forever. Their mastery of perspective, anatomy, and light created timeless masterpieces that continue to inspire artists and captivate audiences five centuries later.',
      imageUrl: 'https://picsum.photos/seed/renaissance/800/1200',
      tags: ['Art', 'History', 'Renaissance'],
      likeCount: 2134,
      commentCount: 298,
      saveCount: 678,
      category: 'Art',
      categoryColor: '#E91E63',
    ),
    Article(
      id: '6',
      title: 'Artificial Intelligence Ethics',
      summary: 'As AI systems become more powerful and prevalent, questions about bias, privacy, and control become increasingly urgent. Leading researchers and ethicists are working to establish frameworks that ensure AI development benefits humanity while minimizing potential harms.',
      imageUrl: 'https://picsum.photos/seed/ai-ethics/800/1200',
      tags: ['AI', 'Ethics', 'Technology'],
      likeCount: 3890,
      commentCount: 645,
      saveCount: 1456,
      category: 'Technology',
      categoryColor: '#4CAF50',
    ),
    Article(
      id: '7',
      title: 'The Great Pyramids Mystery',
      summary: 'Despite centuries of study, the exact methods used to construct the Great Pyramids of Giza remain partially mysterious. New archaeological evidence and advanced scanning technology are revealing secrets about ancient Egyptian engineering that challenge our previous assumptions.',
      imageUrl: 'https://picsum.photos/seed/pyramids/800/1200',
      tags: ['History', 'Egypt', 'Archaeology'],
      likeCount: 5234,
      commentCount: 734,
      saveCount: 2145,
      category: 'History',
      categoryColor: '#FF9800',
    ),
    Article(
      id: '8',
      title: 'Deep Sea Exploration',
      summary: 'The ocean depths hold more mysteries than space. Recent deep-sea expeditions have discovered bizarre new species, underwater volcanoes, and ecosystems that thrive in extreme conditions, expanding our understanding of life\'s possibilities on Earth and beyond.',
      imageUrl: 'https://picsum.photos/seed/deepsea/800/1200',
      tags: ['Ocean', 'Biology', 'Exploration'],
      likeCount: 2987,
      commentCount: 421,
      saveCount: 967,
      category: 'Science',
      categoryColor: '#2196F3',
    ),
    Article(
      id: '9',
      title: 'Space Exploration: Mars Mission',
      summary: 'NASA and private space companies are racing to establish a permanent human presence on Mars. New technologies in propulsion, life support, and habitat construction are making the dream of becoming a multi-planetary species increasingly realistic.',
      imageUrl: 'https://picsum.photos/seed/mars/800/1200',
      tags: ['Space', 'Mars', 'NASA'],
      likeCount: 6789,
      commentCount: 1245,
      saveCount: 3421,
      category: 'Science',
      categoryColor: '#2196F3',
    ),
    Article(
      id: '10',
      title: 'Mindfulness and Mental Health',
      summary: 'Scientific research is validating what ancient practices have taught for millennia: mindfulness meditation can significantly improve mental health. Studies show measurable changes in brain structure and function, offering drug-free treatment options for anxiety and depression.',
      imageUrl: 'https://picsum.photos/seed/mindfulness/800/1200',
      tags: ['Health', 'Psychology', 'Wellness'],
      likeCount: 4123,
      commentCount: 567,
      saveCount: 1876,
      category: 'Health',
      categoryColor: '#9C27B0',
    ),
  ];

  List<Article> getFeed() {
    return List.from(_articles);
  }

  Article? getArticleById(String id) {
    try {
      return _articles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Article toggleLike(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final article = _articles[index];
      final newArticle = article.copyWith(
        isLiked: !article.isLiked,
        likeCount: article.isLiked ? article.likeCount - 1 : article.likeCount + 1,
      );
      _articles[index] = newArticle;
      return newArticle;
    }
    throw Exception('Article not found');
  }

  Article toggleSave(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final article = _articles[index];
      final newArticle = article.copyWith(
        isSaved: !article.isSaved,
        saveCount: article.isSaved ? article.saveCount - 1 : article.saveCount + 1,
      );
      _articles[index] = newArticle;
      return newArticle;
    }
    throw Exception('Article not found');
  }

  void incrementComments(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final article = _articles[index];
      _articles[index] = article.copyWith(
        commentCount: article.commentCount + 1,
      );
    }
  }
}
