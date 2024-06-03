import 'dart:io';

InternetAddress? parseIpAddress(String ipAddressString) {
  // Tente analisar a string do endereço IP
  try {
    return InternetAddress.tryParse(ipAddressString);
  } catch (e) {
    print('Erro ao analisar o endereço IP: $e');
    return null;
  }
}

void main() {
  String ipAddressString = '172.19.240.1';
  InternetAddress? ipAddress = InternetAddress(ipAddressString);
  if (ipAddress != null) {
    print('Endereço IP válido: $ipAddress');
  } else {
    print('Endereço IP inválido.');
  }
}
