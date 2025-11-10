import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/data/models/FavoriteTour.dart';

class FavoriteTourService {
  FavoriteTourService._();
  static final FavoriteTourService instance = FavoriteTourService._();

  final SupabaseClient _db = Supabase.instance.client;
  static const String _view = 'vw_favorite_tours';

  // 🧠 Cache trong RAM
  List<FavoriteTour>? _cachedFavorites;
  DateTime? _lastFetch;

  /// 🩵 Lấy toàn bộ tour yêu thích (mọi user)
  Future<List<FavoriteTour>> fetchAllFavorites() async {
    if (_cachedFavorites != null) return _cachedFavorites!;
    final rows = await _db.from(_view).select();
    _cachedFavorites = (rows as List)
        .map((e) => FavoriteTour.fromMap(e as Map<String, dynamic>))
        .toList();
    _lastFetch = DateTime.now();
    return _cachedFavorites!;
  }

  /// 🩵 Lấy danh sách tour yêu thích theo `int user_id`
  Future<List<FavoriteTour>> fetchFavoritesByUser(int userId) async {
    final rows = await _db.from(_view).select().eq('user_id', userId);
    return (rows as List)
        .map((e) => FavoriteTour.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// 🩵 Lấy danh sách tour yêu thích theo `auth_id (UUID)`
  Future<List<FavoriteTour>> fetchFavoritesByAuth(String userAuthId) async {
    // Lấy user_id thật từ bảng users
    final userData = await _db
        .from('users')
        .select('user_id')
        .eq('auth_id', userAuthId)
        .maybeSingle();

    if (userData == null) return [];

    final userId = userData['user_id'];
    return fetchFavoritesByUser(userId);
  }

  /// ❤️ Lấy danh sách ID tour user hiện tại đã yêu thích
  Future<Set<int>> fetchMyFavoriteTourIds() async {
    final user = _db.auth.currentUser;
    if (user == null) return {};

    final authId = user.id;
    final userData = await _db
        .from('users')
        .select('user_id')
        .eq('auth_id', authId)
        .maybeSingle();

    if (userData == null) return {};

    final userId = userData['user_id'];
    final rows = await _db
        .from('favorite_tours')
        .select('tour_id')
        .eq('user_id', userId);

    final ids = rows.map<int>((e) => e['tour_id'] as int).toSet();
    return ids;
  }

  /// 🩵 Thêm tour yêu thích (dùng INT user_id)
  Future<void> addFavorite(int userId, int tourId) async {
    await _db.from('favorite_tours').insert({
      'user_id': userId,
      'tour_id': tourId,
    });
    clearCache();
  }

  /// 🩵 Xóa tour yêu thích (dùng INT user_id)
  Future<void> removeFavorite(int userId, int tourId) async {
    await _db
        .from('favorite_tours')
        .delete()
        .match({'user_id': userId, 'tour_id': tourId});
    clearCache();
  }

  /// 🩵 Thêm tour yêu thích (UUID)
  Future<void> addFavoriteByAuth(String userAuthId, int tourId) async {
    final userData = await _db
        .from('users')
        .select('user_id')
        .eq('auth_id', userAuthId)
        .maybeSingle();
    if (userData == null) throw Exception('User không tồn tại');

    final userId = userData['user_id'];
    await addFavorite(userId, tourId);
  }

  /// 🩵 Xóa yêu thích (UUID)
  Future<void> removeFavoriteByAuth(String userAuthId, int tourId) async {
    final userData = await _db
        .from('users')
        .select('user_id')
        .eq('auth_id', userAuthId)
        .maybeSingle();
    if (userData == null) throw Exception('User không tồn tại');

    final userId = userData['user_id'];
    await removeFavorite(userId, tourId);
  }

  /// 🩵 Kiểm tra tour có nằm trong danh sách yêu thích không (UUID)
  Future<bool> isFavoriteByAuth(String userAuthId, int tourId) async {
    final userData = await _db
        .from('users')
        .select('user_id')
        .eq('auth_id', userAuthId)
        .maybeSingle();
    if (userData == null) return false;

    final userId = userData['user_id'];
    final rows = await _db
        .from('favorite_tours')
        .select('favorite_id')
        .match({'user_id': userId, 'tour_id': tourId});
    return rows.isNotEmpty;
  }

  /// 🧹 Reset cache (ví dụ khi logout)
  void clearCache() {
    _cachedFavorites = null;
    _lastFetch = null;
  }
}
