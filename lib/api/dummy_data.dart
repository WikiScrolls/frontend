import '../api/models/article.dart';

class DummyData {
  static final List<ArticleModel> articles = [
    ArticleModel(
      id: 'dummy-1',
      title: 'The Roman Empire',
      content: 'The Roman Empire was one of the largest empires in ancient history. At its height, it controlled territories spanning three continents: Europe, Asia, and Africa. The empire was known for its military might, advanced engineering, and lasting cultural influence. Roman innovations in law, governance, and architecture continue to influence modern society. From the Colosseum to aqueducts, their engineering marvels still stand today.',
      likeCount: 1234,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ArticleModel(
      id: 'dummy-2',
      title: 'Quantum Computing',
      content: 'Quantum computing harnesses the principles of quantum mechanics to process information in fundamentally new ways. Unlike classical computers that use bits (0 or 1), quantum computers use quantum bits or qubits, which can exist in multiple states simultaneously. This property, known as superposition, along with quantum entanglement, enables quantum computers to solve certain problems exponentially faster than classical computers.',
      likeCount: 856,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    ArticleModel(
      id: 'dummy-3',
      title: 'The Great Barrier Reef',
      content: 'The Great Barrier Reef is the world\'s largest coral reef system, composed of over 2,900 individual reefs and 900 islands stretching over 2,300 kilometers. Located in the Coral Sea off the coast of Queensland, Australia, it can be seen from outer space and is the world\'s biggest single structure made by living organisms. The reef is home to an incredible diversity of marine life, including over 1,500 species of fish.',
      likeCount: 2341,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ArticleModel(
      id: 'dummy-4',
      title: 'Artificial Intelligence',
      content: 'Artificial Intelligence (AI) refers to the simulation of human intelligence in machines programmed to think and learn like humans. The field encompasses various subfields including machine learning, natural language processing, computer vision, and robotics. AI systems can perform tasks that typically require human intelligence, such as visual perception, speech recognition, decision-making, and language translation.',
      likeCount: 3567,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ArticleModel(
      id: 'dummy-5',
      title: 'The Northern Lights',
      content: 'The Aurora Borealis, commonly known as the Northern Lights, is a natural light display in Earth\'s sky, predominantly seen in high-latitude regions. Auroras are caused by disturbances in the magnetosphere caused by solar wind. These disturbances alter the trajectories of charged particles in the magnetospheric plasma, which precipitate into the upper atmosphere and collide with gas particles, creating stunning displays of colored light.',
      likeCount: 4521,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ArticleModel(
      id: 'dummy-6',
      title: 'Ancient Egypt',
      content: 'Ancient Egypt was a civilization of ancient Northeast Africa, concentrated along the lower reaches of the Nile River. The civilization coalesced around 3100 BC with the political unification of Upper and Lower Egypt under the first pharaoh. Ancient Egypt is famous for its pyramids, mummies, pharaohs, and contributions to mathematics, medicine, and architecture. The society was highly organized and advanced for its time.',
      likeCount: 1876,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    ArticleModel(
      id: 'dummy-7',
      title: 'Black Holes',
      content: 'A black hole is a region of spacetime where gravity is so strong that nothing, not even light, can escape from it. The theory of general relativity predicts that a sufficiently compact mass can deform spacetime to form a black hole. Black holes are formed from the gravitational collapse of massive stars. Despite being invisible, black holes can be detected through their interaction with other matter and electromagnetic radiation.',
      likeCount: 5234,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ArticleModel(
      id: 'dummy-8',
      title: 'Renaissance Period',
      content: 'The Renaissance was a period in European history marking the transition from the Middle Ages to modernity, covering the 15th and 16th centuries. It began in Italy and spread throughout Europe, characterized by a revival of interest in classical learning and values. The period saw advances in art, architecture, politics, science, and literature. Famous figures include Leonardo da Vinci, Michelangelo, and Galileo Galilei.',
      likeCount: 2987,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    ArticleModel(
      id: 'dummy-9',
      title: 'Climate Change',
      content: 'Climate change refers to long-term shifts in temperatures and weather patterns. While these shifts can be natural, since the 1800s, human activities have been the main driver of climate change, primarily due to the burning of fossil fuels which produces heat-trapping gases. The effects include rising temperatures, melting ice caps, rising sea levels, and more frequent extreme weather events.',
      likeCount: 6789,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    ArticleModel(
      id: 'dummy-10',
      title: 'The Mariana Trench',
      content: 'The Mariana Trench is the deepest oceanic trench on Earth, located in the western Pacific Ocean. It reaches a maximum known depth of approximately 10,994 meters at the Challenger Deep. The trench is about 2,550 kilometers long and has an average width of 69 kilometers. Despite the extreme conditions of darkness, cold temperatures, and crushing pressure, unique organisms have been found living in its depths.',
      likeCount: 3421,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    ArticleModel(
      id: 'dummy-11',
      title: 'The Human Brain',
      content: 'The human brain is the central organ of the human nervous system, consisting of approximately 86 billion neurons. It controls most of the activities of the body, processing, integrating, and coordinating information received from the sense organs, and making decisions. The brain is the most complex organ in the human body, responsible for consciousness, thought, memory, emotion, and every process that regulates our body.',
      likeCount: 4123,
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    ArticleModel(
      id: 'dummy-12',
      title: 'The Internet',
      content: 'The Internet is a global system of interconnected computer networks that use the Internet Protocol Suite to link devices worldwide. It carries a vast range of information resources and services, including the World Wide Web, electronic mail, telephony, and file sharing. The Internet has revolutionized communication, commerce, entertainment, and virtually every aspect of modern life since its development in the late 20th century.',
      likeCount: 7654,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static ArticleModel getArticleById(String id) {
    return articles.firstWhere(
      (article) => article.id == id,
      orElse: () => articles.first,
    );
  }

  static List<ArticleModel> getRandomArticles({int count = 10}) {
    final shuffled = List<ArticleModel>.from(articles)..shuffle();
    return shuffled.take(count).toList();
  }
}
