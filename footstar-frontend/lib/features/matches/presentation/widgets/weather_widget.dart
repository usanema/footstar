import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/match_model.dart';
import '../../../venues/data/venue_repository.dart';
import '../../../weather/data/models/weather_model.dart';
import '../../../weather/data/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final MatchModel match;

  const WeatherWidget({super.key, required this.match});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final _venueRepo = VenueRepository();
  final _weatherService = WeatherService();

  WeatherModel? _weather;
  bool _isLoading = true;
  bool _isNotAvailable = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    final now = DateTime.now();
    final matchDate = widget.match.date;

    // Open-Meteo handles up to 16 days ahead. We check 0 to 15 days difference.
    final diff = matchDate.difference(now).inDays;
    if (matchDate.isBefore(now) || diff > 15) {
      if (mounted) {
        setState(() {
          _isNotAvailable = true;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // Default: Katowice coordinates
      double lat = 50.2599;
      double lng = 19.0216;

      if (widget.match.venueId != null) {
        final venue = await _venueRepo.fetchVenueById(widget.match.venueId!);
        if (venue != null) {
          lat = venue.latitude;
          lng = venue.longitude;
        }
      }

      final weather = await _weatherService.fetchWeatherForMatch(
        matchDate,
        lat,
        lng,
      );

      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isNotAvailable = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isNotAvailable || (!_isLoading && _weather == null)) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'POGODA',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_weather!.temperature.toStringAsFixed(1)}°C',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _weather!.weatherDescription,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_weather!.precipitation > 0)
                        Text(
                          'Opady: ${_weather!.precipitation} mm',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.lightBlueAccent,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Text(_weather!.weatherIcon, style: const TextStyle(fontSize: 48)),
        ],
      ),
    );
  }
}
