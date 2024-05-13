import 'package:http/http.dart' as http;
/*
void main() async {
  final hostImages = Uri.parse("https://serpapi.com/search.json");
  String apiKey = "a0abc8c70cff4943c6998d8becfc561aabf6ce028af85253c8e1c7b4d62dd9c6";
  //var url = Uri.parse('$hostImages?q=lampada&engine=google_images&ijn=0&num=8&api_key=$apiKey');
  Map<String, String> body = {
    "q": "lampada",
    "engine":"google_images",
    "ijn": "0",
    "api_key": "apiKey",
    "num": "8"
  };
  var response = await http.get(
    hostImages,
    body: body
  );

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
}
*/