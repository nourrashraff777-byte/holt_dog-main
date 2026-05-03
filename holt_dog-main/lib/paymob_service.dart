import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymobService {
  static const String _apiKey =
      "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRFMU5USTJOeXdpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS5BY2ppbnJkQkxqcFZTbUJ1TjdFYTcyTkEyUDV1LWg0NW1YMENUS1BNcW9hVm52R19aaVZyc040cGR4N2Y5WmRnbHlRT2NKUUwtWjYybm5veFZPbjZaUQ==";
  static const String _integrationId = "YOUR_INTEGRATION_ID";
  static const String _iframeId = "1035526";

  ///  تبدأ عملية الدفع وتعود بـ URL الـ WebView
  Future<String?> getPaymentGatewayUri({
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      //Authentication Token
      final String authToken = await _getAuthToken();

      // (Order Registration)
      final int orderId = await _createOrder(authToken, amount);

      // الخطوة 3: الحصول على Payment Key (مفتاح الدفع النهائي)
      final String paymentKey = await _getPaymentKey(
        authToken: authToken,
        orderId: orderId,
        amount: amount,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      // الخطوة 4: بناء رابط الدفع الذي سيفتح في الـ WebView
      return "https://accept.paymob.com/api/acceptance/iframes/$_iframeId?payment_token=$paymentKey";
    } catch (e) {
      print("Paymob Error: $e");
      return null;
    }
  }

  Future<String> _getAuthToken() async {
    final response = await http.post(
      Uri.parse('https://accept.paymob.com/api/auth/tokens'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'api_key': _apiKey}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      throw Exception('Failed to get Auth Token');
    }
  }

  Future<int> _createOrder(String token, double amount) async {
    final response = await http.post(
      Uri.parse('https://accept.paymob.com/api/ecommerce/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'auth_token': token,
        'delivery_needed': 'false',
        'amount_cents': (amount * 100).toInt().toString(), //
        'currency': 'EGP',
        'items': [],
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['id'];
    } else {
      throw Exception('Failed to create order');
    }
  }

  Future<String> _getPaymentKey({
    required String authToken,
    required int orderId,
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final response = await http.post(
      Uri.parse('https://accept.paymob.com/api/acceptance/payment_keys'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "auth_token": authToken,
        "amount_cents": (amount * 100).toInt().toString(),
        "expiration": 3600,
        "order_id": orderId.toString(),
        "billing_data": {
          "apartment": "NA",
          "email": email,
          "floor": "NA",
          "first_name": firstName,
          "street": "NA",
          "building": "NA",
          "phone_number": phoneNumber,
          "shipping_method": "NA",
          "postal_code": "NA",
          "city": "NA",
          "country": "EG",
          "last_name": lastName,
          "state": "NA"
        },
        "currency": "EGP",
        "integration_id": _integrationId,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      throw Exception('Failed to get Payment Key');
    }
  }
}
