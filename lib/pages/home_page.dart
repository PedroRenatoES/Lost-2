import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/comment_sceen.dart';
import 'package:objetos_perdidos/pages/my_post_screen.dart';
import 'package:objetos_perdidos/pages/porfile_screen.dart';
import 'package:objetos_perdidos/pages/post_create_screen.dart';
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/posts_get.dart';

void main() {
  runApp(const LostAndFoundApp());
}

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Objetos Perdidos3',
      theme: ThemeData(
        primaryColor: const Color(0xFFA50050),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          color: Color(0xFFA50050),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA50050),
            foregroundColor: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFFA50050),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          margin: EdgeInsets.all(10),
          elevation: 3,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Post>> futurePosts;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      futurePosts = fetchPosts();
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Evitar recargar la pantalla actual

    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreatePublicationScreen(),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyPostsScreen(userId: ''),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetos Perdidos5'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<Post>>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay publicaciones disponibles.'));
            }

            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(post: post);
              },
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Crear',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mis Publicaciones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;
    bool useDefaultImage = false;

    try {
      if (post.lostItem.image.isNotEmpty) {
        imageBytes = base64Decode(post.lostItem.image);
      } else {
        useDefaultImage = true;
      }
    } catch (e) {
      useDefaultImage = true;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (useDefaultImage)
            Image.asset(
              'assets/images/skibidihomero.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else if (imageBytes != null)
            Image.memory(
              imageBytes,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.lostItem.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text('Descripción: ${post.lostItem.description}'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateCommentScreen(postId: post.id),
                      ),
                    );
                  },
                  child: const Text('Comentar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
