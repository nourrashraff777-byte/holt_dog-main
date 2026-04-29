import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../user_home/widgets/user_quick_actions_widgets.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const String _predictUrl =
      'https://yh-777-dog-ai-api.hf.space/predict';
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _predictUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
  bool _isLoading = false;
  String _statusMessage = 'Select a dog image to start the scan';
  Map<String, dynamic>? _resultData;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _statusMessage = 'Image selected, press analyze';
      _resultData = null;
    });
  }

  Future<void> _analyzeImage() async {
    final File? selectedImage = _image;
    if (selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Analyzing... please wait a moment';
      _resultData = null;
    });

    final _ApiResponse response = await _sendImage(selectedImage);
    log('API data: ${response.data}');

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data?['success'] == true) {
        _resultData = response.data!;
        _statusMessage = 'Analysis completed';
      } else {
        log('API error: ${response.errorMessage}');
        _statusMessage = response.errorMessage ??
            response.data?['message']?.toString() ??
            'An unexpected error occurred';
      }
    });
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
        final aVal =
            a.value is num ? (a.value as num).toDouble() : double.tryParse('${a.value}') ?? 0;
        final bVal =
            b.value is num ? (b.value as num).toDouble() : double.tryParse('${b.value}') ?? 0;
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
          Text(
            'Analysis Result',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryPurple,
            ),
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
          const UserQuickActionHeader(userName: '', showSearch: false),
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
