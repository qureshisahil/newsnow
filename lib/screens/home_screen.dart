import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/news_provider.dart';
import '../widgets/featured_article_card.dart';
import '../widgets/article_list_tile.dart';
import '../widgets/category_chips.dart';
import '../widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          return RefreshIndicator(
            onRefresh: () => newsProvider.fetchNews(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(context, newsProvider),
                _buildCategorySection(newsProvider),
                if (newsProvider.isLoading && newsProvider.articles.isEmpty)
                  const SliverToBoxAdapter(child: ShimmerLoading()),
                if (newsProvider.error.isNotEmpty)
                  _buildErrorSection(newsProvider),
                if (newsProvider.articles.isNotEmpty)
                  _buildFeaturedSection(newsProvider.articles.first),
                if (newsProvider.articles.length > 1)
                  _buildArticlesList(newsProvider.articles.skip(1).toList()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, NewsProvider newsProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            Icon(
              Icons.newspaper,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'NewsNow',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        if (newsProvider.isLoading)
          Container(
            margin: const EdgeInsets.all(16),
            width: 20,
            height: 20,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => newsProvider.fetchNews(),
          ),
      ],
    );
  }

  Widget _buildCategorySection(NewsProvider newsProvider) {
    return SliverToBoxAdapter(
      child: CategoryChips(
        categories: newsProvider.categories,
        selectedCategory: newsProvider.selectedCategory,
        onCategorySelected: newsProvider.setCategory,
      ),
    );
  }

  Widget _buildErrorSection(NewsProvider newsProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              newsProvider.error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => newsProvider.fetchNews(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(article) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Story',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            FeaturedArticleCard(article: article),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesList(List articles) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: ArticleListTile(
                    article: articles[index],
                    onTap: () => _showArticleBottomSheet(context, articles[index]),
                  ),
                ),
              ),
            );
          },
          childCount: articles.length,
        ),
      ),
    );
  }

  void _showArticleBottomSheet(BuildContext context, article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ArticleBottomSheet(article: article),
    );
  }
}

class _ArticleBottomSheet extends StatelessWidget {
  final dynamic article;

  const _ArticleBottomSheet({required this.article});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (article.urlToImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            article.urlToImage,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey.withOpacity(0.2),
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        article.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (article.sourceName != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                article.sourceName,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            article.timeAgo,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (article.description != null)
                        Text(
                          article.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                // Launch URL
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Read Full Article'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Consumer<BookmarkProvider>(
                            builder: (context, bookmarkProvider, child) {
                              final isBookmarked = bookmarkProvider.isBookmarked(article);
                              return IconButton.outlined(
                                onPressed: () => bookmarkProvider.toggleBookmark(article),
                                icon: Icon(
                                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                  color: isBookmarked 
                                      ? Theme.of(context).colorScheme.primary 
                                      : null,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}