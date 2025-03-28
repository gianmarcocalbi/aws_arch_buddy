enum QnaGameType {
  tellServiceGoal('Tell Goal'),
  guessServiceName('Guess Name'),
  shuffled('Shuffled'),
  onlyFlagged('Only Flagged');

  final String title;

  const QnaGameType(this.title);
}
