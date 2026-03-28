sealed class Tick {
  //Isso aqui representa o índice da batida dentro da compasso
  //Exemplo: Em um compasso 4/4, a primeira batida é 0, a segunda é 1, a terceira é 2 e a quarta é 3
  final int barIndex;

  const Tick({required this.barIndex});
}

final class AccentTick extends Tick {
  const AccentTick({required super.barIndex});
}

final class RegularTick extends Tick {
  const RegularTick({required super.barIndex});
}
