class UserDemo {
  final String id;
  final String name;
  final String email;
  final String password;

  const UserDemo({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });
}

const demoUser = UserDemo(
  id: 'demo1',
  name: 'Test User',
  email: 'demo@trading.com',
  password: 'demo1234',
);
