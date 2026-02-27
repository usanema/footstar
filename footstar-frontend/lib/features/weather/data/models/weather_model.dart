class WeatherModel {
  final double temperature;
  final int weatherCode;
  final double precipitation;
  final DateTime time;

  WeatherModel({
    required this.temperature,
    required this.weatherCode,
    required this.precipitation,
    required this.time,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, int index) {
    return WeatherModel(
      temperature: (json['temperature_2m'][index] as num).toDouble(),
      weatherCode: json['weather_code'][index] as int,
      precipitation: (json['precipitation'][index] as num).toDouble(),
      time: DateTime.parse(json['time'][index] as String).toLocal(),
    );
  }

  /// WMO Weather interpretation codes
  String get weatherIcon {
    switch (weatherCode) {
      case 0:
        return '☀️'; // Clear sky
      case 1:
      case 2:
      case 3:
        return '⛅'; // Mainly clear, partly cloudy, and overcast
      case 45:
      case 48:
        return '🌫️'; // Fog
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return '🌧️'; // Drizzle
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
        return '🌧️'; // Rain
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '❄️'; // Snow
      case 80:
      case 81:
      case 82:
        return '🌦️'; // Rain showers
      case 95:
      case 96:
      case 99:
        return '⛈️'; // Thunderstorm
      default:
        return '❓';
    }
  }

  String get weatherDescription {
    switch (weatherCode) {
      case 0:
        return 'Bezchmurnie';
      case 1:
        return 'Przeważnie słonecznie';
      case 2:
        return 'Częściowe zachmurzenie';
      case 3:
        return 'Pochmurno';
      case 45:
      case 48:
        return 'Mgła';
      case 51:
      case 53:
      case 55:
        return 'Mżawka';
      case 56:
      case 57:
        return 'Marznąca mżawka';
      case 61:
        return 'Słaby deszcz';
      case 63:
        return 'Umiarkowany deszcz';
      case 65:
        return 'Silny deszcz';
      case 66:
      case 67:
        return 'Marznący deszcz';
      case 71:
        return 'Słaby śnieg';
      case 73:
        return 'Umiarkowany śnieg';
      case 75:
        return 'Intensywny śnieg';
      case 77:
        return 'Ziarna śniegu';
      case 80:
      case 81:
      case 82:
        return 'Przelotny deszcz';
      case 85:
      case 86:
        return 'Przelotny śnieg';
      case 95:
        return 'Burza';
      case 96:
      case 99:
        return 'Burza z gradem';
      default:
        return 'Nieznana pogoda';
    }
  }
}
