import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/location_service.dart';
import '../../user_home/widgets/user_quick_actions_widgets.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const String _predictUrl =
      'https://yh-777-dog-ai-api.hf.space/predict';
  static const String _cloudName = 'dk7um4nir';
  static const String _uploadPreset = 'url_default';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _predictUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  static final Dio _uploadDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  bool _isLoading = false;
  String _statusMessage = 'Select a dog image to start the scan';
  Map<String, dynamic>? _resultData;
  bool _saved = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final name = (data['displayName'] ??
                data['name'] ??
                data['username'] ??
                user.displayName ??
                '')
            .toString()
            .trim();

        if (mounted) {
          setState(() => _userName = name);
        }
      }
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _statusMessage = 'Image selected, press analyze';
      _resultData = null;
      _saved = false;
    });
  }

  Future<void> _analyzeImage() async {
    final File? selectedImage = _image;
    if (selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Analyzing... please wait a moment';
      _resultData = null;
      _saved = false;
    });

    final _ApiResponse response = await _sendImage(selectedImage);
    log('API data: ${response.data}');

    if (!mounted) return;

    if (response.isSuccess && response.data?['success'] == true) {
      setState(() {
        _resultData = response.data!;
        _statusMessage = 'Saving to your reports...';
      });
      await _saveScanToFirestore(selectedImage, response.data!);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } else {
      log('API error: ${response.errorMessage}');
      setState(() {
        _isLoading = false;
        _statusMessage = response.errorMessage ??
            response.data?['message']?.toString() ??
            'An unexpected error occurred';
      });
    }
  }

  Future<void> _saveScanToFirestore(
      File image, Map<String, dynamic> aiData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _statusMessage =
          'Analysis completed (sign in to save to your reports)');
      return;
    }

    try {
      // 1. Upload image to Cloudinary.
      final imageUrl = await _uploadToCloudinary(image);
      if (imageUrl == null) {
        setState(() => _statusMessage =
            'Analysis completed (image upload failed, not saved)');
        return;
      }

      // 2. Try to capture the user's location (optional — don't block save).
      double? lat;
      double? lng;
      String address = '';
      try {
        final position = await LocationService.getLocationWithPermission();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          address =
              await LocationService.getCityName(position.latitude, position.longitude);
        }
      } catch (_) {}

      // 3. Compute an MD5 hash of the image bytes for de-duplication.
      String? imageHash;
      try {
        final bytes = await image.readAsBytes();
        imageHash = md5.convert(bytes).toString();
      } catch (_) {}

      // 4. Save to Firestore `scans` collection (matches My Reports schema).
      final analysis = <String, dynamic>{
        'disease': aiData['predicted_disease'],
        'diseaseConfidence': aiData['disease_confidence'],
        'isDog': aiData['is_dog'],
        'mood': aiData['predicted_mood'],
        'moodConfidence': aiData['mood_confidence'],
        'allProbabilities': aiData['all_disease_probabilities'] ?? {},
      };

      await FirebaseFirestore.instance.collection('scans').add({
        'userId': user.uid,
        'imageUrl': imageUrl,
        'imageHash': imageHash,
        'analysis': analysis,
        if (lat != null && lng != null) 'location': GeoPoint(lat, lng),
        'address': address,
        'status': 'Need Help',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        _saved = true;
        _statusMessage = 'Saved to your reports';
      });
    } catch (e) {
      log('Save error: $e');
      if (!mounted) return;
      setState(() => _statusMessage =
          'Analysis completed (save failed: ${e.toString()})');
    }
  }

  Future<String?> _uploadToCloudinary(File image) async {
    try {
      final url =
          'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path),
        'upload_preset': _uploadPreset,
      });
      final res = await _uploadDio.post<dynamic>(url, data: formData);
      if (res.statusCode == 200 && res.data is Map) {
        return res.data['secure_url']?.toString();
      }
      return null;
    } catch (e) {
      log('Cloudinary error: $e');
      return null;
    }
  }

  String _formatPercent(dynamic value) {
    final numValue =
        value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
    return numValue.toStringAsFixed(2);
  }

  double _percentToProgress(dynamic value) {
    final numValue =
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    return (numValue.clamp(0, 100)) / 100;
  }

  String _formatDiseaseName(String value) {
    return value.replaceAll('_', ' ');
  }

  Widget _buildResultSection() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EEFF),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFDCCAFE)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: const CircularProgressIndicator(strokeWidth: 2.2),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                _statusMessage,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_resultData == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundGray.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final Map<String, dynamic> data = _resultData!;
    final Map<String, dynamic> allProbabilities =
        (data['all_disease_probabilities'] as Map<String, dynamic>?) ?? {};
    final String predictedDisease =
        _formatDiseaseName('${data['predicted_disease'] ?? '-'}');
    final String predictedMood = '${data['predicted_mood'] ?? '-'}';
    final bool isDog = data['is_dog'] == true;

    final entries = allProbabilities.entries.toList()
      ..sort((a, b) {
        final aVal = a.value is num
            ? (a.value as num).toDouble()
            : double.tryParse('${a.value}') ?? 0;
        final bVal = b.value is num
            ? (b.value as num).toDouble()
            : double.tryParse('${b.value}') ?? 0;
        return bVal.compareTo(aVal);
      });

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF7F4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE8DEFA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Analysis Result',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPurple,
                ),
              ),
              const Spacer(),
              if (_saved)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green, size: 14.w),
                      SizedBox(width: 4.w),
                      Text(
                        'Saved',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildInfoChip(
                label: 'Dog check',
                value: isDog ? 'Dog detected' : 'Not a dog',
                color: isDog ? Colors.green : Colors.red,
              ),
              _buildInfoChip(
                label: 'Disease',
                value: predictedDisease,
                color: AppColors.primaryPurple,
              ),
              _buildInfoChip(
                label: 'Mood',
                value: predictedMood,
                color: Colors.orange,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildMetricRow(
            title: 'Disease confidence',
            value: _formatPercent(data['disease_confidence']),
            color: AppColors.primaryPurple,
          ),
          SizedBox(height: 8.h),
          _buildMetricRow(
            title: 'Mood confidence',
            value: _formatPercent(data['mood_confidence']),
            color: Colors.orange,
          ),
          SizedBox(height: 14.h),
          Text(
            'All disease probabilities',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          ...entries.map(
            (entry) => _buildProbabilityRow(
              label: _formatDiseaseName(entry.key),
              value: entry.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          '$value%',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProbabilityRow({
    required String label,
    required dynamic value,
  }) {
    final String percentText = _formatPercent(value);
    final double progress = _percentToProgress(value);

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$percentText%',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              minHeight: 7.h,
              value: progress,
              backgroundColor: const Color(0xFFEDE7FA),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  Future<_ApiResponse> _sendImage(File image) async {
    try {
      final FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path),
      });

      final Response<dynamic> response = await _dio.post<dynamic>(
        '',
        data: formData,
      );

      // log('API response: ${response.data}');

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return _ApiResponse.success(response.data as Map<String, dynamic>);
      }

      return _ApiResponse.failure(
        'Server error: ${response.statusCode ?? 'Unknown'}',
      );
    } on DioException catch (error) {
      return _ApiResponse.failure(_mapDioError(error));
    } catch (error) {
      return _ApiResponse.failure('Failed to connect to the server: $error');
    }
  }

  String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timeout, try again';
      case DioExceptionType.connectionError:
        return 'No connection to the server, check your internet connection';
      case DioExceptionType.badResponse:
        return 'Server returned an error: ${error.response?.statusCode ?? 'Unknown'}';
      default:
        return 'An unexpected error occurred while connecting';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          UserQuickActionHeader(userName: _userName, showSearch: false),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            _image!,
                            height: 260.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 240.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                AppColors.backgroundGray.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.primaryPurple,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.photo_library_outlined,
                              size: 80.w,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                  SizedBox(height: 24.h),
                  Text(
                    'AI Scan',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Upload your dog image and run an instant AI health and mood analysis.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Upload Image from gallery'),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading || _image == null ? null : _analyzeImage,
                      icon: _isLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.analytics_outlined),
                      label: Text(
                        _isLoading ? 'Analyzing...' : 'Start Analysis Now',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primaryPurple.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildResultSection(),
                  SizedBox(height: 140.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiResponse {
  final bool isSuccess;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  const _ApiResponse._({required this.isSuccess, this.data, this.errorMessage});

  factory _ApiResponse.success(Map<String, dynamic> data) =>
      _ApiResponse._(isSuccess: true, data: data);

  factory _ApiResponse.failure(String message) =>
      _ApiResponse._(isSuccess: false, errorMessage: message);
}
