import 'dart:io'; // Required for Platform checks

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../../models/stock.dart';
import '../../models/user.dart';
import '../../services/stock_services.dart';
import '../../services/user_services.dart'; // Use the new UserService

class QRCodeScannerScreen extends StatefulWidget {
  const QRCodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Stock? _scannedStock;
  User? _assignedUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _scanComplete = false; // Flag to prevent multiple scans

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Stock QR Code')),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _buildQrView(context),
          if (_isLoading) const CircularProgressIndicator(),
          if (_scannedStock != null) _buildStockInfoCard(),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0 // Smaller scan area for smaller screens
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (_scanComplete || _isLoading)
        return; // Prevent processing if already loading or scan complete

      setState(() {
        _isLoading = true;
        _scanComplete = true; // Mark scan as complete to avoid re-scanning
        _errorMessage = null;
        _scannedStock = null;
        _assignedUser = null;
      });

      // Pause camera after scan
      await controller.pauseCamera();

      try {
        final String? itemId = scanData.code;
        if (itemId == null || itemId.isEmpty) {
          throw Exception('Invalid QR Code Data');
        }

        // Fetch stock item
        final stock = await StockService().getStockById(itemId);
        if (stock == null) {
          throw Exception('Stock item not found for ID: $itemId');
        }

        setState(() {
          _scannedStock = stock;
        });

        // Fetch user if userId exists
        if (stock.userId != null) {
          final user = await UserService().getUserById(stock.userId!);
          setState(() {
            _assignedUser = user; // Can be null if user not found
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });
        _showSnackBar(_errorMessage!);
        // Resume camera on error to allow re-scanning
        await controller.resumeCamera();
        setState(() {
          _scanComplete = false; // Allow scanning again on error
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
        // Keep camera paused if successful scan and data displayed
        // User can navigate back or tap card to dismiss and rescan (optional)
      }
    });
  }

  Widget _buildStockInfoCard() {
    if (_scannedStock == null) return const SizedBox.shrink();

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item Details',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall), // Updated style
              const Divider(),
              _buildInfoRow('Name:', _scannedStock!.name),
              _buildInfoRow('Model:', _scannedStock!.model),
              _buildInfoRow(
                  'Created:', dateFormat.format(_scannedStock!.creationDate)),
              _buildInfoRow('Status:', _scannedStock!.status),
              if (_assignedUser != null) ...[
                const SizedBox(height: 8),
                Text('Assigned User:',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium), // Updated style
                _buildInfoRow('  Name:', _assignedUser!.name),
                _buildInfoRow('  Email:', _assignedUser!.email),
              ] else if (_scannedStock!.userId != null) ...[
                const SizedBox(height: 8),
                Text('Assigned User:',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium), // Updated style
                _buildInfoRow('  User ID:', _scannedStock!.userId.toString()),
                _buildInfoRow('  (User details not found)', ''),
              ] else ...[
                const SizedBox(height: 8),
                Text('Assigned User:',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium), // Updated style
                _buildInfoRow('  Status:', 'Not Assigned'),
              ],
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Reset state and resume camera for a new scan
                    setState(() {
                      _scannedStock = null;
                      _assignedUser = null;
                      _errorMessage = null;
                      _scanComplete = false;
                    });
                    await controller?.resumeCamera();
                  },
                  child: const Text('Scan Another'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      _showSnackBar('Camera permission not granted');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
