// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:newsnow/widgets/featured_article_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/news_provider.dart';
import '../widgets/article_list_tile.dart';
import '../widgets/category_chips.dart';
import '../widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => newsProvider.fetchNews(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text('NewsNow', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  centerTitle: true,
                  floating: true,
                  pinned: true,
                  snap: true,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60.0),
                    child: CategoryChips(
                      categories: newsProvider.categories,
                      selectedCategory: newsProvider.selectedCategory,
                      onCategorySelected: (category) => newsProvider.setCategory(category),
                    ),
                  ),
                ),
                _buildSliverBody(newsProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverBody(NewsProvider newsProvider) {
    if (newsProvider.isLoading && newsProvider.articles.isEmpty) {
      return const SliverFillRemaining(
        child: ShimmerLoading(),
      );
    }

    if (newsProvider.error.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Failed to load news: ${newsProvider.error}', textAlign: TextAlign.center),
        )),
      );
    }

    if (newsProvider.articles.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: Text('No articles found for this category.')),
      );
    }

    // A SliverList allows us to build a list of widgets within a CustomScrollView
    return AnimationLimiter(
      child: SliverList(
        delegate: SliverChildListDelegate(
          AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              // Hero Section for the top story
              if (newsProvider.articles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Top Story',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              if (newsProvider.articles.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: InkWell(
                    onTap: () => _launchURL(newsProvider.articles.first.url),
                    borderRadius: BorderRadius.circular(16),
                    child: FeaturedArticleCard(article: newsProvider.articles.first),
                  ),
                ),
              
              // "Latest News" Section Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Latest News',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              // The rest of the articles
              ...newsProvider.articles.skip(1).map(
                (article) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: ArticleListTile(
                    article: article,
                    onTap: () => _launchURL(article.url),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}