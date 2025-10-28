// lib/features/data_extraction/data/mock_data.dart

/// Simulerer outputtet fra en AI-analyse (JSON-format).
const Map<String, dynamic> mockAnalysisData = {
  'customerName': 'John Anderson',
  'phone': '555-0123',
  'email': 'john.anderson@example.com',
  'address': '123 Main Street, Copenhagen',
  'job': 'Water Heater Installation',
  'assignment': 'Kunden ønsker at udskifte en defekt vandvarmer med en ny energieffektiv model. Standardinstallation er påkrævet.',
  'preferredDates': ['Tuesday next week', 'Wednesday next week'],
  'partsNeeded': [
    {'name': 'High-Efficiency Water Heater, 50L', 'sku': 'WH-50L-E', 'price': 2500.0},
    {'name': 'Pressure Relief Valve', 'sku': 'PRV-1/2', 'price': 150.0},
    {'name': 'Copper Piping, 3m', 'sku': 'CP-3M', 'price': 75.0},
  ],
  // Total estimat er summen af dele + 1500 for arbejdsløn (mock)
  'totalEstimate': 4225.0,
  'notes': 'Kunden nævnte at have et budget på omkring 3000 dollars, vær opmærksom på prisen.',
};