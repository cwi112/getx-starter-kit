/// 서버 응답을 안전하게 변환하는 유틸. 실패해도 예외 대신 기본값을 돌려준다.
abstract final class ParsingUtil {
  static List<T> jsonToList<T>(
    List<dynamic>? jsonList,
    T Function(Map<String, dynamic> json) fromJson,
  ) =>
      jsonList?.map((json) => fromJson(json as Map<String, dynamic>)).toList() ?? [];

  /// "1,000" / "+500" 같은 문자열도 정수로 변환한다. 실패하면 0.
  static int stringToInt(String? str) =>
      int.tryParse((str ?? '').replaceAll(',', '').replaceAll('+', '').trim()) ?? 0;

  static double stringToDouble(String? str) =>
      double.tryParse((str ?? '').replaceAll(',', '').trim()) ?? 0;

  static BigInt stringToBigInt(String? str) =>
      BigInt.tryParse((str ?? '').replaceAll(',', '').trim()) ?? BigInt.zero;
}
