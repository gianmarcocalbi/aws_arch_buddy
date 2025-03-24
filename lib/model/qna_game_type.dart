enum QnaGameType {
  tellServiceGoal('Tell Goal'),
  guessServiceName('Guess Name'),
  shuffled('Shuffled');

  final String title;

  const QnaGameType(this.title);
}
