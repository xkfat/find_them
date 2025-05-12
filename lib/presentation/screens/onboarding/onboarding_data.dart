class OnboardingItem {
  final String title;
  final String description;
  final String imageAsset;
  
  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
  
  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Welcome to FindThem',
      description: 'Where hope exists!',
      imageAsset: 'assets/images/onboarding/onboarding1.png',
    ),
    OnboardingItem(
      title: 'Together, we can bring missing loved ones back home.',
      description: 'Our community works together to find missing persons.',
      imageAsset: 'assets/images/onboarding/onboarding2.png',
    ),
    OnboardingItem(
      title: 'Join our network',
      description: 'Sign up to report missing persons or help in the search.',
      imageAsset: 'assets/images/onboarding/onboarding3.png',
    ),
  ];
}