import 'package:vietnam_handbook/features/notes/domain/entities/vietnam_note.dart';

/// Verified Vietnamese banknote scans from Ron Wise's World Paper Money
/// (banknote.ws). Local copies live under `assets/notes/` for offline use.
abstract final class VietnamNotesCatalog {
  static const _catalogBase = 'http://banknote.ws/COLLECTION/countries/ASI/VIE';
  static const _assetDir = 'assets/notes';

  static String _asset(String file) => '$_assetDir/$file';

  static String _page(String pick) => '$_catalogBase/$pick.htm';

  static NoteVariation _variation({
    required String series,
    required NoteSide side,
    required String file,
    required String pick,
  }) {
    return NoteVariation(
      series: series,
      side: side,
      imageUrl: _asset(file),
      sourcePageUrl: _page(pick),
    );
  }

  static List<NoteVariation> _pair({
    required String series,
    required String frontFile,
    required String backFile,
    required String pick,
  }) {
    return [
      _variation(
        series: series,
        side: NoteSide.front,
        file: frontFile,
        pick: pick,
      ),
      _variation(
        series: series,
        side: NoteSide.back,
        file: backFile,
        pick: pick,
      ),
    ];
  }

  static final List<VietnamNote> notes = [
    VietnamNote(
      amountVnd: 500000,
      title: '500,000 Đồng',
      variations: _pair(
        series: 'Polymer',
        frontFile: 'VIE0124ao.jpg',
        backFile: 'VIE0124ar.jpg',
        pick: 'VIE0124',
      ),
    ),
    VietnamNote(
      amountVnd: 200000,
      title: '200,000 Đồng',
      variations: _pair(
        series: 'Polymer',
        frontFile: 'VIE0123ao.jpg',
        backFile: 'VIE0123ar.jpg',
        pick: 'VIE0123',
      ),
    ),
    VietnamNote(
      amountVnd: 100000,
      title: '100,000 Đồng',
      variations: [
        ..._pair(
          series: 'Polymer',
          frontFile: 'VIE0122ao.jpg',
          backFile: 'VIE0122ar.jpg',
          pick: 'VIE0122',
        ),
        ..._pair(
          series: 'Cotton',
          frontFile: 'VIE0117ao.jpg',
          backFile: 'VIE0117ar.jpg',
          pick: 'VIE0117',
        ),
      ],
    ),
    VietnamNote(
      amountVnd: 50000,
      title: '50,000 Đồng',
      variations: [
        ..._pair(
          series: 'Polymer',
          frontFile: 'VIE0121ao.jpg',
          backFile: 'VIE0121ar.jpg',
          pick: 'VIE0121',
        ),
        ..._pair(
          series: 'Cotton',
          frontFile: 'VIE0116ao.jpg',
          backFile: 'VIE0116ar.jpg',
          pick: 'VIE0116',
        ),
      ],
    ),
    VietnamNote(
      amountVnd: 20000,
      title: '20,000 Đồng',
      variations: [
        ..._pair(
          series: 'Polymer',
          frontFile: 'VIE0120ao.jpg',
          backFile: 'VIE0120ar.jpg',
          pick: 'VIE0120',
        ),
        ..._pair(
          series: 'Cotton',
          frontFile: 'VIE0110ao.jpg',
          backFile: 'VIE0110ar.jpg',
          pick: 'VIE0110',
        ),
      ],
    ),
    VietnamNote(
      amountVnd: 10000,
      title: '10,000 Đồng',
      variations: [
        ..._pair(
          series: 'Polymer',
          frontFile: 'VIE0119ao.jpg',
          backFile: 'VIE0119ar.jpg',
          pick: 'VIE0119',
        ),
        ..._pair(
          series: 'Cotton',
          frontFile: 'VIE0115ao.jpg',
          backFile: 'VIE0115ar.jpg',
          pick: 'VIE0115',
        ),
      ],
    ),
    VietnamNote(
      amountVnd: 5000,
      title: '5,000 Đồng',
      variations: _pair(
        series: 'Cotton',
        frontFile: 'VIE0104ao.jpg',
        backFile: 'VIE0104ar.jpg',
        pick: 'VIE0104',
      ),
    ),
    VietnamNote(
      amountVnd: 2000,
      title: '2,000 Đồng',
      variations: _pair(
        series: 'Cotton',
        frontFile: 'VIE0103ao.jpg',
        backFile: 'VIE0103ar.jpg',
        pick: 'VIE0103',
      ),
    ),
    VietnamNote(
      amountVnd: 1000,
      title: '1,000 Đồng',
      variations: _pair(
        series: 'Cotton',
        frontFile: 'VIE0102ao.jpg',
        backFile: 'VIE0102ar.jpg',
        pick: 'VIE0102',
      ),
    ),
    VietnamNote(
      amountVnd: 500,
      title: '500 Đồng',
      variations: _pair(
        series: 'Cotton',
        frontFile: 'VIE0101ao.jpg',
        backFile: 'VIE0101ar.jpg',
        pick: 'VIE0101',
      ),
    ),
  ];
}
