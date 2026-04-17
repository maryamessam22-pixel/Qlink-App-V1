import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../models/models.dart';
import '../../../services/providers.dart';
import '../../../services/supabase_service.dart';

class ProfileVaultScreen extends StatefulWidget {
  final String profileId;
  final String profileName;

  const ProfileVaultScreen({
    super.key,
    required this.profileId,
    required this.profileName,
  });

  @override
  ConsumerState<ProfileVaultScreen> createState() => _ProfileVaultScreenState();
}

class _ProfileVaultScreenState extends State<ProfileVaultScreen> {
  List<VaultFile> _files = [];
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _loading = true);
    try {
      _files = await SupabaseService.fetchVaultFiles(widget.profileId);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
    setState(() => _uploading = true);
    try {
      final file = File(result.files.single.path!);
      final name = result.files.single.name;
      final uploaded =
          await SupabaseService.uploadVaultFile(widget.profileId, file, name);
      setState(() => _files.insert(0, uploaded));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('File uploaded successfully'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _deleteFile(VaultFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete file?'),
        content: Text('This will permanently delete "${file.fileName}".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;
    await SupabaseService.deleteVaultFile(file.id, file.fileUrl);
    setState(() => _files.removeWhere((f) => f.id == file.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.profileName, style: AppTextStyles.heading3),
            Text('Medical Vault', style: AppTextStyles.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _uploading ? null : _uploadFile,
            icon: _uploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload_file_outlined,
                    color: AppColors.primaryBlue),
          ),
        ],
      ),
      body: _loading
          ? const AppLoadingWidget()
          : _files.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.folder_open_outlined,
                  title: 'No files yet',
                  subtitle: 'Upload medical reports, X-rays, or documents',
                  action: GradientButton(
                    label: 'Upload File',
                    icon: Icons.upload,
                    width: 180,
                    onTap: _uploadFile,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _files.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _FileCard(
                    file: _files[i],
                    onDelete: () => _deleteFile(_files[i]),
                  ),
                ),
      floatingActionButton: _files.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _uploadFile,
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Upload', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}

class _FileCard extends StatelessWidget {
  final VaultFile file;
  final VoidCallback onDelete;

  const _FileCard({required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isImage = file.isImage;
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isImage && file.fileUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(file.fileUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_outlined,
                                color: AppColors.primaryBlue)))
                : Icon(
                    file.fileType == 'application/pdf'
                        ? Icons.picture_as_pdf_outlined
                        : Icons.insert_drive_file_outlined,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName ?? 'Medical File',
                  style: AppTextStyles.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                if (file.uploadedAt != null)
                  Text(
                    _formatDate(file.uploadedAt!),
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new,
                    color: AppColors.primaryBlue, size: 20),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
