import 'package:flutter/material.dart';
import 'package:liquid_glass_native/liquid_glass_native.dart';

enum WeatherStatusType { empty, loading, error }

class WeatherStatusView extends StatelessWidget {
  const WeatherStatusView({
    super.key,
    required this.type,
    this.message,
    this.onRetry,
  });

  final WeatherStatusType type;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (type) {
              WeatherStatusType.loading => LiquidGlassActivityIndicator(
                  size: 36,
                  tint: Colors.white.withValues(alpha: 0.8),
                ),
              WeatherStatusType.error => Icon(
                  Icons.cloud_off,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 48,
                ),
              WeatherStatusType.empty => Icon(
                  Icons.search,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 48,
                ),
            },
            const SizedBox(height: 16),
            Text(
              message ??
                  switch (type) {
                    WeatherStatusType.empty => 'Search a city',
                    WeatherStatusType.loading => 'Loading...',
                    WeatherStatusType.error => 'Something went wrong',
                  },
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 17,
              ),
            ),
            if (type == WeatherStatusType.error && onRetry != null) ...[
              const SizedBox(height: 20),
              LiquidGlassContainer(
                borderRadius: 14,
                onPressed: onRetry,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
