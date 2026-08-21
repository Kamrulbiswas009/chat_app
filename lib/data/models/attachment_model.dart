class AttachmentModel {
  final String id;
  final String url;
  final String type; // 'image', 'video', 'audio', 'file'
  final String? fileName;
  final int? fileSize;
  final String? mimeType;

  AttachmentModel({
    required this.id,
    required this.url,
    required this.type,
    this.fileName,
    this.fileSize,
    this.mimeType,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? 'file',
      fileName: json['file_name'] ?? json['fileName'],
      fileSize: json['file_size'] ?? json['fileSize'],
      mimeType: json['mime_type'] ?? json['mimeType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
    };
  }
}
