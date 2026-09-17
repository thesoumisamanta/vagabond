class LegalSubsection {
  final String subtitle;
  final List<String> items;

  const LegalSubsection({
    required this.subtitle,
    required this.items,
  });
}

class LegalSection {
  final int? sectionNumber;
  final String title;
  final String? preamble;
  final List<LegalSubsection>? subsections;
  final List<String>? items;
  final String? closing;

  const LegalSection({
    this.sectionNumber,
    required this.title,
    this.preamble,
    this.subsections,
    this.items,
    this.closing,
  });
}

