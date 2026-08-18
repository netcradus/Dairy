/// Banner Item Model for Sawariya Dairy hero carousels
class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String buttonText;
  final String imageUrl;
  final String routePath;

  const BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.buttonText,
    required this.imageUrl,
    this.routePath = '/shop',
  });
}
