import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class VersionInfo extends StatefulWidget {
  final bool showBuildInfo;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const VersionInfo({
    Key? key,
    this.showBuildInfo = true,
    this.textStyle,
    this.backgroundColor,
    this.padding,
  }) : super(key: key);

  @override
  State<VersionInfo> createState() => _VersionInfoState();
}

class _VersionInfoState extends State<VersionInfo> {
  String _version = '';
  String _buildNumber = '';
  String _buildDate = '';
  String _gitCommit = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      // Charger les informations depuis version.json
      final String response = await rootBundle.loadString('version.json');
      final Map<String, dynamic> versionData = json.decode(response);
      
      setState(() {
        _version = versionData['version'] ?? '1.0.0';
        _buildNumber = versionData['build_number']?.toString() ?? '1';
        _buildDate = versionData['build_date'] ?? _getCurrentDate();
        _gitCommit = versionData['git_commit'] ?? 'unknown';
        _isLoading = false;
      });
    } catch (e) {
      // Fallback si le fichier n'est pas trouvé
      setState(() {
        _version = '1.0.0';
        _buildNumber = '1';
        _buildDate = _getCurrentDate();
        _gitCommit = 'unknown';
        _isLoading = false;
      });
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ArgentEnveloppes v$_version',
            style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.showBuildInfo) ...[
            const SizedBox(height: 4),
            Text(
              'Build #$_buildNumber',
              style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Déployé le $_buildDate',
              style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall,
            ),
            if (_gitCommit != 'unknown') ...[
              Text(
                'Commit: ${_gitCommit.substring(0, 7)}',
                style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Widget compact pour afficher uniquement la version
class CompactVersionInfo extends StatelessWidget {
  final TextStyle? textStyle;

  const CompactVersionInfo({
    Key? key,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getVersionString(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        return Text(
          snapshot.data!,
          style: textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        );
      },
    );
  }

  Future<String> _getVersionString() async {
    try {
      final String response = await rootBundle.loadString('version.json');
      final Map<String, dynamic> versionData = json.decode(response);
      final String version = versionData['version'] ?? '1.0.0';
      return 'v$version';
    } catch (e) {
      return 'v1.0.0';
    }
  }
}

/// Widget pour le footer avec informations de version
class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CompactVersionInfo(),
          Text(
            '© 2025 ArgentEnveloppes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
