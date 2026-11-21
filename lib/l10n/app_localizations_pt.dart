// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Metrônomo';

  @override
  String get navMetronome => 'Metrônomo';

  @override
  String get navPresets => 'Presets';

  @override
  String get navSetlists => 'Setlists';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get create => 'Criar';

  @override
  String get delete => 'Excluir';

  @override
  String get activeBadge => 'ATIVO';

  @override
  String get bpmUnit => 'BPM';

  @override
  String get untitledPreset => 'Preset sem título';

  @override
  String get untitledSetlist => 'Setlist sem título';

  @override
  String presetCopyName(String originalName) {
    return '$originalName (Cópia)';
  }

  @override
  String get themeModeSystem => 'Sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Escuro';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get soundClickLabel => 'Click';

  @override
  String get soundClickDescription => 'Clique nítido de precisão de estúdio';

  @override
  String get soundWoodBlockLabel => 'Madeira';

  @override
  String get soundWoodBlockDescription =>
      'Bloco de madeira quente e ressonante';

  @override
  String get soundBeepLabel => 'Bipe';

  @override
  String get soundBeepDescription => 'Tom digital claro de metrônomo';

  @override
  String get soundDrumsLabel => 'Bateria';

  @override
  String get soundDrumsDescription => 'Bumbo, aro e chimbal acústicos';

  @override
  String get subdivisionQuarter => 'Semínima';

  @override
  String get subdivisionEighths => 'Colcheias';

  @override
  String get subdivisionTriplets => 'Tercinas';

  @override
  String get subdivisionSixteenths => 'Semicolcheias';

  @override
  String pulsesPerBeat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pulsos por tempo',
      one: '1 pulso por tempo',
    );
    return '$_temp0';
  }

  @override
  String subdivisionOptionSemantics(String label, int count) {
    return 'Subdivisão $label ($count por tempo)';
  }

  @override
  String get beatAccentStrong => 'Forte';

  @override
  String get beatAccentMedium => 'Médio';

  @override
  String get beatAccentWeak => 'Fraco';

  @override
  String get beatAccentSubdivision => 'Subdivisão';

  @override
  String get metronomeHeader => 'METRÔNOMO';

  @override
  String get savePresetAction => 'Salvar Preset';

  @override
  String savedPresetSnackbar(String name) {
    return 'Preset \"$name\" salvo';
  }

  @override
  String beatIndicatorPlayingSemantics(int beat, int total) {
    return 'Tempo $beat de $total';
  }

  @override
  String beatIndicatorStoppedSemantics(int beatCount) {
    String _temp0 = intl.Intl.pluralLogic(
      beatCount,
      locale: localeName,
      other: '$beatCount tempos',
      one: '1 tempo',
    );
    return 'Indicador de pulso parado, $_temp0 por compasso';
  }

  @override
  String get decreaseBpmSemantics => 'Diminuir BPM em 1';

  @override
  String get increaseBpmSemantics => 'Aumentar BPM em 1';

  @override
  String bpmValueSemantics(int bpm, String tempoMarking) {
    return '$bpm batidas por minuto, $tempoMarking';
  }

  @override
  String get bpmSliderSemantics =>
      'Controle deslizante de ajuste rápido de BPM';

  @override
  String bpmWithUnit(int bpm) {
    return '$bpm BPM';
  }

  @override
  String get tapTempoSemantics => 'Tap tempo';

  @override
  String get tapTempoLabel => 'TAP TEMPO';

  @override
  String get stopMetronomeSemantics => 'Parar metrônomo';

  @override
  String get startMetronomeSemantics => 'Iniciar metrônomo';

  @override
  String get timeSignatureCaption => 'COMPASSO';

  @override
  String timeSignatureSelectorSemantics(String label) {
    return 'Fórmula de compasso $label. Toque para alterar.';
  }

  @override
  String get subdivisionCaption => 'SUBDIVISÃO';

  @override
  String subdivisionSelectorSemantics(String label) {
    return 'Subdivisão $label. Toque para alterar.';
  }

  @override
  String get downbeatAccentOnTooltip => 'Acento no tempo 1 LIGADO';

  @override
  String get downbeatAccentOffTooltip => 'Acento no tempo 1 DESLIGADO';

  @override
  String get downbeatAccentOnSemantics => 'Acento no tempo 1 ativado';

  @override
  String get downbeatAccentOffSemantics => 'Acento no tempo 1 desativado';

  @override
  String get timeSignatureSheetTitle => 'COMPASSO';

  @override
  String get timeSignaturePresetsSection => 'PREDEFINIÇÕES';

  @override
  String timeSignatureOptionSemantics(String label) {
    return 'Compasso $label';
  }

  @override
  String get customMeterSection => 'COMPASSO PERSONALIZADO';

  @override
  String get beatsPerBarLabel => 'TEMPOS POR COMPASSO';

  @override
  String get numeratorRangeLabel => 'Numerador (1–16)';

  @override
  String get decreaseBeatsPerBarSemantics => 'Diminuir tempos por compasso';

  @override
  String get increaseBeatsPerBarSemantics => 'Aumentar tempos por compasso';

  @override
  String get noteValueDenominatorLabel => 'FIGURA (DENOMINADOR)';

  @override
  String denominatorSemantics(int denom) {
    return 'Denominador $denom';
  }

  @override
  String get subdivisionsSheetTitle => 'SUBDIVISÕES';

  @override
  String get nextBarBadge => 'PRÓX. COMPASSO';

  @override
  String get exitSetlistTooltip => 'Sair da setlist';

  @override
  String get previousSongSemantics => 'Música anterior na setlist';

  @override
  String get nextSongSemantics => 'Próxima música na setlist';

  @override
  String setlistPosition(int current, int total) {
    return '$current de $total';
  }

  @override
  String get preferencesHeader => 'PREFERÊNCIAS';

  @override
  String get backToMetronomeTooltip => 'Voltar ao metrônomo';

  @override
  String get appearanceSectionHeader => 'APARÊNCIA';

  @override
  String get appearanceDescription =>
      'Escolha entre modo escuro, modo claro ou siga a aparência do sistema.';

  @override
  String get languageSectionHeader => 'IDIOMA';

  @override
  String get languageDescription =>
      'Escolha o idioma do aplicativo ou siga o idioma do dispositivo.';

  @override
  String get soundsSectionHeader => 'SONS E VOLUMES';

  @override
  String get soundsDescription =>
      'Selecione o timbre do clique, equilibre os volumes dos tempos forte, fraco e subdivisões ou silencie o áudio mantendo o pulso visual.';

  @override
  String get muteAudioTitle => 'Silenciar áudio';

  @override
  String get muteAudioSubtitle =>
      'Silencia o clique mantendo o indicador visual ativo';

  @override
  String get strongBeatVolumeLabel => 'Tempo Forte';

  @override
  String get weakBeatsVolumeLabel => 'Tempos Fracos';

  @override
  String get subdivisionsVolumeLabel => 'Subdivisões';

  @override
  String volumeSliderSemantics(String label) {
    return 'Volume de $label';
  }

  @override
  String get presetsHeader => 'PRESETS';

  @override
  String get newPresetButton => 'Novo Preset';

  @override
  String get searchPresetsPlaceholder => 'Buscar presets por nome...';

  @override
  String get clearSearchTooltip => 'Limpar busca';

  @override
  String presetCardSemantics(String name, int bpm, String timeSignature) {
    return '$name, $bpm BPM, $timeSignature';
  }

  @override
  String unfavoritePresetTooltip(String name) {
    return 'Remover $name dos favoritos';
  }

  @override
  String favoritePresetTooltip(String name) {
    return 'Favoritar $name';
  }

  @override
  String presetBpmTempoSummary(int bpm, String tempoMarking) {
    return '$bpm BPM · $tempoMarking';
  }

  @override
  String get accentOnBadge => 'Acento LIGADO';

  @override
  String get accentOffBadge => 'Acento DESLIGADO';

  @override
  String editPresetTooltip(String name) {
    return 'Editar $name';
  }

  @override
  String duplicatePresetTooltip(String name) {
    return 'Duplicar $name';
  }

  @override
  String deletePresetTooltip(String name) {
    return 'Excluir $name';
  }

  @override
  String noPresetsMatchQuery(String query) {
    return 'Nenhum preset corresponde a \"$query\"';
  }

  @override
  String get noPresetsSavedTitle => 'Nenhum preset salvo ainda';

  @override
  String get noPresetsMatchSubtitle =>
      'Tente outra palavra-chave ou limpe o filtro de busca.';

  @override
  String get noPresetsSavedSubtitle =>
      'Salve andamento, compasso, subdivisão e notas de ensaio para acesso rápido em um toque.';

  @override
  String get clearSearchButton => 'Limpar Busca';

  @override
  String get createPresetButton => 'Criar Preset';

  @override
  String get deletePresetDialogTitle => 'Excluir Preset?';

  @override
  String deletePresetDialogMessage(String name) {
    return 'Tem certeza de que deseja excluir \"$name\"? Esta ação não pode ser desfeita.';
  }

  @override
  String deletePresetSetlistWarning(int count, String setlistNames) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Aviso: Usado em $count setlists: $setlistNames. Excluir este preset irá removê-lo dessas setlists.',
      one:
          'Aviso: Usado em 1 setlist: $setlistNames. Excluir este preset irá removê-lo dessa setlist.',
    );
    return '$_temp0';
  }

  @override
  String get presetNameRequiredError => 'Digite um nome para salvar o preset.';

  @override
  String get editPresetSheetTitle => 'EDITAR PRESET';

  @override
  String get newPresetSheetTitle => 'NOVO PRESET';

  @override
  String get removeFromFavoritesTooltip => 'Remover dos favoritos';

  @override
  String get markAsFavoriteTooltip => 'Marcar como favorito';

  @override
  String get presetNameLabel => 'Nome do preset';

  @override
  String get presetNamePlaceholder => 'ex: Levada de Abertura';

  @override
  String get presetNoteLabel => 'Nota (opcional)';

  @override
  String get presetNotePlaceholder => 'ex: Contagem no início';

  @override
  String get tempoSectionLabel => 'ANDAMENTO';

  @override
  String get decreasePresetBpmSemantics => 'Diminuir BPM do preset';

  @override
  String get increasePresetBpmSemantics => 'Aumentar BPM do preset';

  @override
  String beatsCountLabel(int count) {
    return 'Tempos: $count';
  }

  @override
  String get accentOnBeat1Label => 'ACENTO NO TEMPO 1';

  @override
  String get saveChangesButton => 'Salvar Alterações';

  @override
  String get savePresetButton => 'Salvar Preset';

  @override
  String get setlistsHeader => 'SETLISTS';

  @override
  String get newSetlistButton => 'Nova Setlist';

  @override
  String get newSetlistDialogTitle => 'Nova Setlist';

  @override
  String get renameSetlistDialogTitle => 'Renomear Setlist';

  @override
  String get deleteSetlistDialogTitle => 'Excluir Setlist?';

  @override
  String deleteSetlistDialogMessage(String name) {
    return 'Tem certeza de que deseja excluir \"$name\"? Seus presets salvos permanecerão na biblioteca.';
  }

  @override
  String get emptySetlistPreview =>
      'Setlist vazia — toque para adicionar presets';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count músicas',
      one: '1 música',
      zero: '0 músicas',
    );
    return '$_temp0';
  }

  @override
  String setlistCardSemantics(String name, String songCountLabel) {
    return '$name, $songCountLabel';
  }

  @override
  String setlistCardSubtitle(String songCountLabel, String previewText) {
    return '$songCountLabel · $previewText';
  }

  @override
  String get activateSetlistButton => 'Ativar';

  @override
  String renameSetlistTooltip(String name) {
    return 'Renomear $name';
  }

  @override
  String deleteSetlistTooltip(String name) {
    return 'Excluir $name';
  }

  @override
  String get noSetlistsTitle => 'Nenhuma setlist ainda';

  @override
  String get noSetlistsSubtitle =>
      'Agrupe seus presets salvos em setlists ordenadas para shows ou ensaios com transições sincronizadas por compasso.';

  @override
  String get createSetlistButton => 'Criar Setlist';

  @override
  String get setlistNameRequiredError => 'Digite um nome para a setlist.';

  @override
  String get setlistNameLabel => 'Nome da setlist';

  @override
  String get setlistNamePlaceholder => 'ex: Show de Sexta';

  @override
  String setlistSongCountAndReorderHint(String songCountLabel) {
    return '$songCountLabel · Arraste para reordenar';
  }

  @override
  String get renameSetlistGenericTooltip => 'Renomear setlist';

  @override
  String get addPresetButton => 'Adicionar Preset';

  @override
  String get emptySetlistDetailTitle => 'Esta setlist ainda não tem músicas.';

  @override
  String get emptySetlistDetailSubtitle =>
      'Toque em \"Adicionar Preset\" acima para montar a ordem das músicas.';

  @override
  String removePresetTooltip(String name) {
    return 'Remover $name';
  }

  @override
  String get addPresetPickerTitle => 'ADICIONAR PRESET À SETLIST';

  @override
  String get addPresetPickerEmpty =>
      'Nenhum preset salvo ainda. Crie um preset na aba Presets primeiro.';
}
