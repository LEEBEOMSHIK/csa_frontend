import 'package:csa_frontend/features/character/models/saved_character.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

class CharacterService {
  CharacterService._();
  static final CharacterService instance = CharacterService._();

  Future<List<SavedCharacter>> fetchMyCharacters() async {
    final data = await ApiClient.instance.get('/characters');
    return (data as List<dynamic>)
        .map((e) => SavedCharacter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SavedCharacter> create(String name, List<int> variants) async {
    final data = await ApiClient.instance.post(
      '/characters',
      data: {'name': name, 'variants': variants},
    );
    return SavedCharacter.fromJson(data as Map<String, dynamic>);
  }

  Future<SavedCharacter> update(int id, String name, List<int> variants) async {
    final data = await ApiClient.instance.put(
      '/characters/$id',
      data: {'name': name, 'variants': variants},
    );
    return SavedCharacter.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await ApiClient.instance.delete('/characters/$id');
  }
}
