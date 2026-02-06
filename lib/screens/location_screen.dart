import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/utilities/constants.dart';
import 'package:weather_app/services/weather.dart';
import 'city_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, this.locationWeather});

  final dynamic locationWeather;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final WeatherModel weather = WeatherModel();

  int? temperature;
  String? weatherIcon;
  String? cityName;
  String? weatherMessage;

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = '⚠️';
        weatherMessage = 'Unable to get weather data';
        cityName = '';
        return;
      }

      final num temp = weatherData['main']['temp'] as num;
      temperature = temp.toInt();

      final int condition = (weatherData['weather'][0]['id'] as num).toInt();
      weatherIcon = weather.getWeatherIcon(condition);

      weatherMessage = weather.getMessage(temperature!);
      cityName = weatherData['name'];
    });
  }

  Future<void> _refreshByLocation() async {
    final weatherData = await weather.getLocationWeather();
    updateUI(weatherData);
  }

  Future<void> _pickCityAndFetch() async {
    final typedName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CityScreen()),
    );

    if (typedName != null) {
      final weatherData = await weather.getCityWeather(typedName);
      updateUI(weatherData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final tempText = '${temperature ?? 0}°';
    final iconText = weatherIcon ?? '❓';
    final cityText = (cityName == null || cityName!.trim().isEmpty) ? '—' : cityName!;
    final messageText = weatherMessage ?? '—';

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'images/location_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Contrast overlay (keeps content readable)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.70),
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.75),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top actions (modern filled-tonal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Atualizar pela localização',
                        onPressed: _refreshByLocation,
                        icon: const Icon(Icons.near_me),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Buscar por cidade',
                        onPressed: _pickCityAndFetch,
                        icon: const Icon(Icons.location_city),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Main content card
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: _GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cityText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      tempText,
                                      style: kTempTextStyle.copyWith(height: 0.95),
                                    ),
                                    const SizedBox(width: 12),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        iconText,
                                        style: kConditionTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  messageText,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.92),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom info strip
                  _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: cs.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$messageText in $cityText',
                              textAlign: TextAlign.left,
                              style: kMessageTextStyle.copyWith(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.92),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
