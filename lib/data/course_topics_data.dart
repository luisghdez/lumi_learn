import 'package:flutter/material.dart';

final List<String> courseCategories = [
  'Nursing',
  'Computer Science',
  'Business',
  'Mathematics',
  'Physics',
  'Chemistry',
  'Biology',
  'History',
  'Psychology',
  'Engineering',
  'Art',
  'Law',
  'Economics',
  'Medicine',
];

final Map<String, IconData> categoryIcons = {
  'Nursing': Icons.local_hospital,
  'Computer Science': Icons.computer,
  'Business': Icons.business_center,
  'Mathematics': Icons.calculate,
  'Physics': Icons.science,
  'Chemistry': Icons.science_outlined,
  'Biology': Icons.nature,
  'History': Icons.menu_book,
  'Psychology': Icons.psychology,
  'Engineering': Icons.engineering,
  'Art': Icons.palette,
  'Law': Icons.gavel,
  'Economics': Icons.attach_money,
  'Medicine': Icons.medical_services,
};

final List<Map<String, String>> courseTopics = [
  // Nursing
  {
    'title': 'How Nurses Think Fast',
    'subtitle': 'Learn how nurses make quick, high-stakes decisions',
    'category': 'Nursing',
  },
  {
    'title': 'Why We Check Vitals',
    'subtitle': 'Understand the meaning behind heart rate, BP & more',
    'category': 'Nursing',
  },
  {
    'title': 'How IVs Actually Work',
    'subtitle': 'Follow fluids as they enter the bloodstream',
    'category': 'Nursing',
  },

  // Computer Science
  {
    'title': 'How the Internet Works',
    'subtitle': 'Understand the path your message takes online',
    'category': 'Computer Science',
  },
  {
    'title': 'Intro to Neural Networks',
    'subtitle': 'How machines mimic the human brain to learn',
    'category': 'Computer Science',
  },
  {
    'title': 'Computer Networks 101',
    'subtitle': 'The foundation of everything from Wi-Fi to websites',
    'category': 'Computer Science',
  },

  // Business
  {
    'title': 'Why Companies Go Viral',
    'subtitle': 'Explore the psychology behind viral products',
    'category': 'Business',
  },
  {
    'title': 'Pricing Tricks You See Daily',
    'subtitle': 'Learn the psychology of 4.99 and “limited time only”',
    'category': 'Business',
  },
  {
    'title': 'How Startups Raise Millions',
    'subtitle': 'Understand seed rounds, Series A, and venture capital',
    'category': 'Business',
  },

  // Mathematics
  {
    'title': 'Why Math is in Nature',
    'subtitle': 'Discover how patterns like the Fibonacci spiral occur',
    'category': 'Mathematics',
  },
  {
    'title': 'How Cryptography Protects You',
    'subtitle': 'Learn the math that keeps your messages private',
    'category': 'Mathematics',
  },
  {
    'title': 'How Algorithms Rank You',
    'subtitle': 'Understand the math behind your TikTok feed',
    'category': 'Mathematics',
  },

  // Physics
  {
    'title': 'Why Time Slows Near Light',
    'subtitle': 'Einstein’s mind-bending idea made simple',
    'category': 'Physics',
  },
  {
    'title': 'The Science of Black Holes',
    'subtitle': 'What happens when gravity breaks reality?',
    'category': 'Physics',
  },
  {
    'title': 'Why Things Float or Sink',
    'subtitle': 'Discover the forces acting all around you',
    'category': 'Physics',
  },

  // Chemistry
  {
    'title': 'Why Carbon is Special',
    'subtitle': 'The king of chemistry and basis of life',
    'category': 'Chemistry',
  },
  {
    'title': 'What is pH and Why It Matters',
    'subtitle': 'From soap to soda, learn the power of acids & bases',
    'category': 'Chemistry',
  },
  {
    'title': 'How Fire Works',
    'subtitle': 'Understand the chemistry behind flames',
    'category': 'Chemistry',
  },

  // Biology
  {
    'title': 'Why You Look Like Your Parents',
    'subtitle': 'A crash course in DNA and inheritance',
    'category': 'Biology',
  },
  {
    'title': 'What Happens in Your Cells',
    'subtitle': 'Inside the engine room of your body',
    'category': 'Biology',
  },
  {
    'title': 'What Makes a Virus Alive?',
    'subtitle': 'Explore the blurry line between life and non-life',
    'category': 'Biology',
  },

  // History
  {
    'title': 'Why the Roman Empire Fell',
    'subtitle': 'Lessons from one of history’s biggest collapses',
    'category': 'History',
  },
  {
    'title': 'The First Viral Tech in History',
    'subtitle': 'How the printing press made ideas unstoppable',
    'category': 'History',
  },
  {
    'title': 'A 5-Minute History of Democracy',
    'subtitle': 'Where voting came from and how it evolved',
    'category': 'History',
  },

  // Psychology
  {
    'title': 'Why We Procrastinate',
    'subtitle': 'The brain science behind delaying things',
    'category': 'Psychology',
  },
  {
    'title': 'What is Impostor Syndrome?',
    'subtitle': 'Why smart people feel like fakes—and how to fix it',
    'category': 'Psychology',
  },
  {
    'title': 'How Habits Are Built (and Broken)',
    'subtitle': 'Make real change by understanding habit loops',
    'category': 'Psychology',
  },

  // Engineering
  {
    'title': 'How Bridges Hold Massive Weight',
    'subtitle': 'Discover the design secrets of civil engineers',
    'category': 'Engineering',
  },
  {
    'title': 'Why Planes Stay in the Air',
    'subtitle': 'A quick tour of lift, thrust, and drag',
    'category': 'Engineering',
  },
  {
    'title': 'How Self-Driving Cars See the Road',
    'subtitle': 'Learn the sensors and systems powering autonomy',
    'category': 'Engineering',
  },

  // Art
  {
    'title': 'Why Mona Lisa is Famous',
    'subtitle': 'Unpack the secrets behind the smile',
    'category': 'Art',
  },
  {
    'title': 'Color Theory 101',
    'subtitle': 'Learn how artists create mood with color',
    'category': 'Art',
  },
  {
    'title': 'How Perspective Changed Art',
    'subtitle': 'The illusion that made paintings pop',
    'category': 'Art',
  },

  // Law
  {
    'title': 'What Rights Do You Actually Have?',
    'subtitle': 'A simple breakdown of freedom of speech and more',
    'category': 'Law',
  },
  {
    'title': 'How a Bill Becomes a Law',
    'subtitle': 'Follow a bill’s journey from paper to power',
    'category': 'Law',
  },
  {
    'title': 'The Basics of Criminal vs Civil Law',
    'subtitle': 'What’s the difference between suing and arresting?',
    'category': 'Law',
  },

  // Economics
  {
    'title': 'Why Eggs Cost More This Year',
    'subtitle': 'Inflation, supply chains, and global prices explained',
    'category': 'Economics',
  },
  {
    'title': 'How the Stock Market Works',
    'subtitle': 'What you’re actually buying when you buy a stock',
    'category': 'Economics',
  },
  {
    'title': 'What is a Recession?',
    'subtitle': 'Learn what happens when economies shrink',
    'category': 'Economics',
  },

  // Medicine
  {
    'title': 'How Your Immune System Works',
    'subtitle': 'Meet the cells that defend your body 24/7',
    'category': 'Medicine',
  },
  {
    'title': 'What’s in a Vaccine?',
    'subtitle': 'Understand how vaccines teach your body to fight',
    'category': 'Medicine',
  },
  {
    'title': 'How Doctors Diagnose Illnesses',
    'subtitle': 'Learn how symptoms turn into answers',
    'category': 'Medicine',
  },
];
