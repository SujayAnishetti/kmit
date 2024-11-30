import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class OCRScanPage extends StatefulWidget {
  @override
  _OCRScanPageState createState() => _OCRScanPageState();
}

class _OCRScanPageState extends State<OCRScanPage> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _picker = ImagePicker();
  final Gemini gemini = Gemini.instance;
  String _geminiResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Automatically open the camera when the page is loaded
    _scanText();
  }

  // Method to scan text using camera input
  Future<void> _scanText() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Instead of showing OCR text, directly ask for the product name
      if (recognizedText.text.isEmpty) {
        _showProductNameDialog();
      } else {
        setState(() {
          // Text is detected, still prompt for the product name, but do not display OCR result
          _showProductNameDialog();
        });
      }
    } catch (e) {
      _showProductNameDialog(); // Handle errors similarly by showing the product name dialog
    }
  }

  // Method to show the dialog when no text is detected or after OCR scan
  Future<void> _showProductNameDialog() async {
    final TextEditingController productNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Product Name'),
          content: TextField(
            controller: productNameController,
            decoration: InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (productNameController.text.isNotEmpty) {
                  _generateGeminiPrompt(productNameController.text);
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Method to generate a prompt and call Gemini API
  Future<void> _generateGeminiPrompt(String productName) async {
    try {
      setState(() {
        _isLoading = true; // Show loading state
        _geminiResponse = ''; // Clear previous response
      });

      // Generate a request to Gemini
      final prompt =
          "Give me a overall score, individual scores for Energy, Saturated fats, Sugars, Salt, Fibre, Fruits, vegetables, legumes on 10 for this product: $productName";

      // Call Gemini API with the prompt
      final text = await gemini.text(prompt);

      // Handle the response
      if (text != null && text.content != null) {
        setState(() {
          _geminiResponse = text.content?.parts?.map((e) => e.text).join(' ') ?? 'No response';
        });
      } else {
        setState(() {
          _geminiResponse = 'Error: No content returned from Gemini.';
        });
      }
    } catch (e) {
      setState(() {
        _geminiResponse = 'Error: Failed to generate Gemini prompt.';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading state
      });
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OCR Scan')),
      body: Column(
        children: [
          if (_isLoading)
            CircularProgressIndicator(), // Show loading indicator when waiting for response
          if (_geminiResponse.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _geminiResponse,
                style: TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
