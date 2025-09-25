// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:newsnow/api/news_api_service.dart';
import 'package:newsnow/models/article.dart';
import 'package:newsnow/widgets/article_card.dart';
import 'package:newsnow/widgets/category_nav.dart';
import 'package:newsnow/widgets/hero_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsApiService _newsService = NewsApiService();
  Future<List<Article>>? _articlesFuture;
  String _selectedCategory = 'general';

  final List<String> _categories = [
    'general', 'business', 'entertainment', 'health', 'science', 'sports', 'technology'
  ];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  void _fetchNews() {
    setState(() {
      if (_selectedCategory == 'general') {
        _articlesFuture = _newsService.fetchTopHeadlines();
      } else {
        _articlesFuture = _newsService.fetchNewsByCategory(_selectedCategory);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('NewsNow', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            centerTitle: true,
            pinned: true, // <-- THIS MAKES THE HEADER STICKY
            floating: false,
            snap: false,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: CategoryNavBar(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) => setState(() {
                  _selectedCategory = category;
                  _fetchNews();
                }),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Article>>(
              future: _articlesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox(height: 400, child: Center(child: Text('Could not load top story.')));
                }
                return HeroCard(article: snapshot.data!.first);
              },
            ),
          ),
          FutureBuilder<List<Article>>(
            future: _articlesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(child: Center(child: Text('Error: ${snapshot.error}')));
              }
              if (snapshot.hasData && snapshot.data!.length > 1) {
                final articles = snapshot.data!.skip(1).toList(); // Skip the hero article
                return SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400.0,
                      mainAxisSpacing: 20.0,
                      crossAxisSpacing: 20.0,
                      childAspectRatio: 0.9,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        // WRAP THE CARD IN ANIMATION WIDGETS
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: (MediaQuery.of(context).size.width / 400).floor(),
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: ArticleCard(article: articles[index]),
                            ),
                          ),
                        );
                      },
                      childCount: articles.length,
                    ),
                  ),
                );
              }
              return const SliverFillRemaining(child: Center(child: Text('No more news found.')));
            },
          ),
        ],
      ),
    );
  }
}