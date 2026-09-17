class Contact {
  final String id;
  final String name;
  final String vpa;
  final String initials;
  final String category;
  final int avatarColor;
  final String? phone;

  const Contact({
    required this.id,
    required this.name,
    required this.vpa,
    required this.initials,
    required this.category,
    required this.avatarColor,
    this.phone,
  });

  static const List<Contact> recents = [
    Contact(
      id: 'c1',
      name: 'Suresh Electronics',
      vpa: 'merchantstore@oksbi',
      initials: 'SE',
      category: 'Electronics & Retail',
      avatarColor: 0xFF0B57D0,
    ),
    Contact(
      id: 'c2',
      name: 'Starbucks Coffee',
      vpa: 'starbucks.retail@hdfcbank',
      initials: 'SB',
      category: 'Food & Beverage',
      avatarColor: 0xFF006241,
    ),
    Contact(
      id: 'c3',
      name: 'Priya Sharma',
      vpa: 'priya.sharma@okaxis',
      initials: 'PS',
      category: 'Personal Transfer',
      avatarColor: 0xFF7C3AED,
    ),
    Contact(
      id: 'c4',
      name: 'DMart Supermarket',
      vpa: 'dmart.pos4@icici',
      initials: 'DM',
      category: 'Groceries',
      avatarColor: 0xFFE11D48,
    ),
    Contact(
      id: 'c5',
      name: 'Aman Verma',
      vpa: 'aman.verma@oksbi',
      initials: 'AV',
      category: 'Personal Transfer',
      avatarColor: 0xFF0284C7,
    ),
  ];
}
