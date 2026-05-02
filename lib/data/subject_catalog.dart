class SubjectCategory {
  const SubjectCategory({
    required this.title,
    required this.subjects,
  });

  final String title;
  final List<String> subjects;
}

const List<SubjectCategory> subjectCatalog = [
  SubjectCategory(
    title: 'Sciences',
    subjects: [
      'AP Biology',
      'AP Physics 1',
      'Physics',
      'AP Chemistry',
      'Chemistry',
      'AP Environmental Science',
      'AP Physics 2',
      'AP Physics C: E&M',
      'AP Physics C: Mechanics',
      'Electrical Engineering',
    ],
  ),
  SubjectCategory(
    title: 'Computer Science & Technology',
    subjects: [
      'AP Computer Science A',
      'Computer Science / Programming',
      'AP Computer Science Principles',
      'Honors Computer Education',
    ],
  ),
  SubjectCategory(
    title: 'PE & Health',
    subjects: [
      'Health & Medicine',
    ],
  ),
  SubjectCategory(
    title: 'Maths',
    subjects: [
      'Algebra',
      'Algebra 1',
      'Algebra 2',
      'Geometry',
      'Trigonometry',
      'Pre-Calculus',
      'Calculus 1',
      'Statistics',
      'AP Statistics',
      'AP Pre-Calculus',
      'Differential Equations',
      'AP Business with Personal Finance',
    ],
  ),
  SubjectCategory(
    title: 'Humanities & Social Sciences',
    subjects: [
      'AP US Government & Politics',
      'US History',
      'AP US History',
      'AP European History',
      'World History',
      'AP World History',
      'AP Human Geography',
      'AP Comparative Government & Politics',
      'Macroeconomics',
      'AP Psychology',
      'AP Macroeconomics',
      'AP Microeconomics',
      'World Geography',
      'AP African American Studies',
      'Civics',
      'AP Research',
    ],
  ),
  SubjectCategory(
    title: 'English & Literature',
    subjects: [
      'AP English Language',
      'AP English Literature',
    ],
  ),
  SubjectCategory(
    title: 'Arts & Music',
    subjects: [
      'Art & Design',
      'AP Music Theory',
      'AP Art History',
    ],
  ),
  SubjectCategory(
    title: 'Foreign Languages',
    subjects: [
      'AP Spanish Language',
      'AP Spanish Literature',
      'AP French',
      'AP German',
      'AP Chinese',
      'AP Italian',
      'AP Japanese',
      'AP Latin',
    ],
  ),
];

final List<String> allSubjects = subjectCatalog
    .expand((category) => category.subjects)
    .toList(growable: false);
