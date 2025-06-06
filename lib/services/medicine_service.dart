import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine_model.dart'; // pastikan path sesuai file model Medicine kamu

class MedicineService {
  final String baseUrl = "https://6842e96ce1347494c31e6af5.mockapi.io";

  // Ambil daftar semua medicine dari API
  Future<List<Medicine>> fetchMedicines() async {
    final url = Uri.parse('$baseUrl/goods');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Medicine.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load eletronics');
    }
  }

  // Ambil detail medicine berdasarkan id
  Future<Medicine> fetchMedicineById(String id) async {
    final url = Uri.parse('$baseUrl/goods/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      return Medicine.fromJson(jsonMap);
    } else {
      throw Exception('Failed to load medicine detail');
    }
  }
}
