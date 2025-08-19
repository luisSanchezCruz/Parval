import 'dart:convert';

import 'package:http/http.dart' as http;

const fastForexApiKey = '214bdfac51-339cde49a4-t189jw';

class CurrencyService {
  
  Future<double?> getUSDToDOP() async {
    const url = 'https://api.beta.fastforex.io/fetch-multi?from=USD&to=DOP';

    final response = await http.get(
      Uri.parse(url),
      headers: {'X-API-Key': fastForexApiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['results']['DOP'];
    } else {
      return null;
    }
  }
}
