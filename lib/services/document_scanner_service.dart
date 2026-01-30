import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class DocumentScannerService {
  static final DocumentScannerService _instance = DocumentScannerService._internal();

  factory DocumentScannerService() {
    return _instance;
  }

  DocumentScannerService._internal();

  /// Launch the interactive ML Kit Document Scanner UI
  /// The user captures or selects an image within the scanner
  /// Returns the path to the processed document image
  static Future<String?> launchDocumentScanner() async {
    DocumentScanner? scanner;
    try {
      // Create scanner options optimized for ID card scanning
      final documentOptions = DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.filter, // Enables filtering and enhancement
        pageLimit: 1, // We only need one page (one side of ID)
        isGalleryImport: true, // Allow importing from gallery as fallback
      );

      // Create scanner instance
      scanner = DocumentScanner(options: documentOptions);

      // Launch the interactive scanner UI
      // User will capture/select image within the scanner
      final result = await scanner.scanDocument();

      if (result.images.isEmpty) {
        print('No images extracted from document scan');
        return null;
      }

      // Get the first (and only) processed image path
      final processedImagePath = result.images.first;
      
      print('Document scanned successfully: $processedImagePath');
      return processedImagePath;
    } catch (e) {
      print('Error scanning document: $e');
      return null;
    } finally {
      // Clean up resources
      scanner?.close();
    }
  }

  /// Get PDF from scanned document (interactive scanner)
  static Future<String?> launchDocumentScannerAndGetPDF() async {
    DocumentScanner? scanner;
    try {
      final documentOptions = DocumentScannerOptions(
        documentFormat: DocumentFormat.pdf,
        mode: ScannerMode.filter,
        pageLimit: 1,
        isGalleryImport: true,
      );

      scanner = DocumentScanner(options: documentOptions);
      final result = await scanner.scanDocument();

      if (result.pdf == null) {
        print('No PDF generated from document scan');
        return null;
      }

      // Get PDF file URI
      final pdfUri = result.pdf!.uri;
      print('PDF generated: $pdfUri');
      return pdfUri;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    } finally {
      scanner?.close();
    }
  }

  /// Get JPEG image from scanned document (interactive scanner)
  static Future<String?> launchDocumentScannerForJPEG() async {
    DocumentScanner? scanner;
    try {
      final documentOptions = DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.filter,
        pageLimit: 1,
        isGalleryImport: true,
      );

      scanner = DocumentScanner(options: documentOptions);
      final result = await scanner.scanDocument();

      if (result.images.isEmpty) {
        print('No images from scanner');
        return null;
      }

      return result.images.first;
    } catch (e) {
      print('Error scanning document: $e');
      return null;
    } finally {
      scanner?.close();
    }
  }
}
