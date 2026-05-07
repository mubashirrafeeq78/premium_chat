import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';
import 'config.dart';
import 'models.dart';
import 'routes.dart';
import 'storage.dart';

enum ProviderFlowState { none, submitted, approved }

/// --- Background compress task for compute() ---
class _CompressArgs {
  final Uint8List bytes;
  final int maxSide;
  final int quality;
  const _CompressArgs(this.bytes, this.maxSide, this.quality);
}

Uint8List _compressInIsolate(_CompressArgs a) {
  final decoded = img.decodeImage(a.bytes);
  if (decoded == null) return a.bytes;

  final w = decoded.width;
  final h = decoded.height;
  final longest = w > h ? w : h;

  img.Image out = decoded;

  if (longest > a.maxSide) {
    final scale = a.maxSide / longest;
    final newW = (w * scale).round();
    final newH = (h * scale).round();
    out = img.copyResize(
      decoded,
      width: newW,
      height: newH,
      interpolation: img.Interpolation.average,
    );
  }

  final jpg = img.encodeJpg(out, quality: a.quality);
  return Uint8List.fromList(jpg);
}

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _api = ApiClient(baseUrl: AppConfig.baseUrl);
  final _picker = ImagePicker();

  String _role = "buyer"; // buyer/provider
  bool _loading = false;
  String _error = "";

  ProviderFlowState _providerState = ProviderFlowState.none;

  // previews (show instantly)
  Uint8List? _profilePreview;
  Uint8List? _cnicFrontPreview;
  Uint8List? _cnicBackPreview;
  Uint8List? _selfiePreview;

  // base64 payloads (compressed)
  String _profilePicBase64 = "";
  String _cnicFrontBase64 = "";
  String _cnicBackBase64 = "";
  String _selfieBase64 = "";

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickAndSet({
    required ImageSource source,
    required bool useFrontCamera,
    required int maxSide,
    required int quality,
    required void Function(Uint8List previewBytes) setPreviewFast,
    required void Function(String b64) setB64,
  }) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        preferredCameraDevice: useFrontCamera ? CameraDevice.front : CameraDevice.rear,
        imageQuality: 100, // we compress ourselves
      );
      if (x == null) return;

      final raw = await x.readAsBytes();

      // ✅ show preview immediately (no wait)
      setPreviewFast(raw);

      // ✅ compress in background (reduces hang)
      final compressed = await compute(_compressInIsolate, _CompressArgs(raw, maxSide, quality));

      // extra safety: avoid huge payloads
      if (compressed.lengthInBytes > 2 * 1024 * 1024) {
        // if still too big, compress more
        final compressed2 = await compute(_compressInIsolate, _CompressArgs(raw, 720, 60));
        setB64(base64Encode(compressed2));
      } else {
        setB64(base64Encode(compressed));
      }

      if (mounted) setState(() => _error = "");
    } catch (e) {
      if (mounted) setState(() => _error = "Image error: $e");
    }
  }

  Future<void> _submit() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = "";
    });

    try {
      final token = await AppStorage.getToken();
      final phone = await AppStorage.getPhone();
      if (token == null || token.isEmpty) throw Exception("Token missing. Login again.");
      if (phone == null || phone.isEmpty) throw Exception("Phone missing. Login again.");

      final name = _name.text.trim();
      if (name.isEmpty) {
        setState(() => _error = "Please enter profile name");
        return;
      }

      if (_role == "provider") {
        if (_cnicFrontBase64.isEmpty || _cnicBackBase64.isEmpty || _selfieBase64.isEmpty) {
          setState(() => _error = "Provider verification required: CNIC Front, CNIC Back, Live Selfie");
          return;
        }
      }

      final body = <String, dynamic>{
        "name": name,
        "role": _role,
        "profilePicBase64": _profilePicBase64,
        "cnicFrontBase64": _role == "provider" ? _cnicFrontBase64 : "",
        "cnicBackBase64": _role == "provider" ? _cnicBackBase64 : "",
        "selfieBase64": _role == "provider" ? _selfieBase64 : "",
      };

      final res = await _api.postJson("/profile/save", token: token, body: body);

      // Save minimal user locally
      await AppStorage.saveUser(
        UserModel(
          phone: phone,
          name: name,
          role: _role,
          avatarBase64: _profilePicBase64,
        ),
      );

      if (!mounted) return;

      if (_role == "buyer") {
        Navigator.pushReplacementNamed(context, AppRoutes.homeBuyer);
        return;
      }

      // provider flow: read status from response
      final status =
          (res["status"] ?? (res["provider"] is Map ? res["provider"]["status"] : null) ?? "pending")
              .toString()
              .toLowerCase();

      setState(() {
        _providerState = (status == "approved") ? ProviderFlowState.approved : ProviderFlowState.submitted;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------- UI helpers ----------------
  Widget _errorBox() {
    if (_error.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Text(
        _error,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _typeButton({
    required String value,
    required IconData icon,
    required String text,
  }) {
    final selected = _role == value;
    return Expanded(
      child: InkWell(
        onTap: _loading
            ? null
            : () {
                setState(() {
                  _role = value;
                  _error = "";
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8EAF6) : const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF3F51B5) : const Color(0xFFCFD8DC),
              width: 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF3F51B5).withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? const Color(0xFF3F51B5) : const Color(0xFF333333)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? const Color(0xFF3F51B5) : const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool circularPreview,
    required Uint8List? previewBytes,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _loading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBDBDBD), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF616161))),
            const SizedBox(height: 2),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, color: Color(0xFF90A4AE))),
            const SizedBox(height: 10),
            if (previewBytes != null)
              circularPreview
                  ? Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00C853), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C853).withOpacity(0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          )
                        ],
                        image: DecorationImage(image: MemoryImage(previewBytes), fit: BoxFit.cover),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(previewBytes, height: 110, width: double.infinity, fit: BoxFit.cover),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _greenButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF00C853), Color(0xFF00E676)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C853).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
    );
  }

  // ---------------- Provider Popups ----------------
  Widget _popup({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showButton = false,
  }) {
    return Center(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(22),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 22)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 32, backgroundColor: const Color(0xFF00C853), child: Icon(icon, color: Colors.white, size: 34)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF616161))),
            if (showButton) ...[
              const SizedBox(height: 16),
              _greenButton(
                text: "Go To Application",
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.homeProvider),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // provider submitted popup
    if (_providerState == ProviderFlowState.submitted) {
      return Scaffold(
        backgroundColor: Colors.black54,
        body: _popup(
          icon: Icons.check,
          title: "Request Submitted",
          subtitle: "Your documents are under review.",
          showButton: false,
        ),
      );
    }

    // provider approved popup
    if (_providerState == ProviderFlowState.approved) {
      return Scaffold(
        backgroundColor: Colors.black54,
        body: _popup(
          icon: Icons.star,
          title: "Congratulations!",
          subtitle: "Your account has been approved.",
          showButton: true,
        ),
      );
    }

    final buttonText = _role == "provider" ? "Submit for Review" : "Go To Application";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F7FA), Color(0xFFC8E6C9), Color(0xFFFFF9C4)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFF2F2F2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "👤 Profile Setup",
                        style: TextStyle(color: Color(0xFF3F51B5), fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Complete your profile and choose your user type.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF90A4AE), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 18),

                      // Profile picture
                      InkWell(
                        onTap: _loading
                            ? null
                            : () async {
                                await _pickAndSet(
                                  source: ImageSource.gallery,
                                  useFrontCamera: false,
                                  maxSide: 720,
                                  quality: 70,
                                  setPreviewFast: (raw) => setState(() => _profilePreview = raw),
                                  setB64: (b64) => setState(() => _profilePicBase64 = b64),
                                );
                              },
                        child: Column(
                          children: [
                            Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFCFD8DC), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                                image: DecorationImage(
                                  image: _profilePreview != null
                                      ? MemoryImage(_profilePreview!)
                                      : const NetworkImage("https://via.placeholder.com/90?text=Pic") as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Upload Profile Picture",
                              style: TextStyle(color: Color(0xFF3F51B5), fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Name input
                      TextField(
                        controller: _name,
                        enabled: !_loading,
                        decoration: InputDecoration(
                          hintText: "Profile Name",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFCFD8DC)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF3F51B5), width: 1.4),
                          ),
                        ),
                      ),

                      _errorBox(),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _typeButton(value: "provider", icon: Icons.build, text: "I’m a Service Provider"),
                          const SizedBox(width: 10),
                          _typeButton(value: "buyer", icon: Icons.handshake, text: "I’m a Service buyer"),
                        ],
                      ),

                      if (_role == "provider") ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 12),
                          decoration: const BoxDecoration(
                            border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Live Verification (Mandatory for Provider)",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF3F51B5), fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 14),

                              _uploadCard(
                                icon: Icons.badge,
                                title: "CNIC Front Side",
                                subtitle: "(Tap to take Live Photo)",
                                circularPreview: false,
                                previewBytes: _cnicFrontPreview,
                                onTap: () async {
                                  await _pickAndSet(
                                    source: ImageSource.camera,
                                    useFrontCamera: false,
                                    maxSide: 1024,
                                    quality: 65,
                                    setPreviewFast: (raw) => setState(() => _cnicFrontPreview = raw),
                                    setB64: (b64) => setState(() => _cnicFrontBase64 = b64),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),

                              _uploadCard(
                                icon: Icons.credit_card,
                                title: "CNIC Back Side",
                                subtitle: "(Tap to take Live Photo)",
                                circularPreview: false,
                                previewBytes: _cnicBackPreview,
                                onTap: () async {
                                  await _pickAndSet(
                                    source: ImageSource.camera,
                                    useFrontCamera: false,
                                    maxSide: 1024,
                                    quality: 65,
                                    setPreviewFast: (raw) => setState(() => _cnicBackPreview = raw),
                                    setB64: (b64) => setState(() => _cnicBackBase64 = b64),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),

                              _uploadCard(
                                icon: Icons.camera_alt,
                                title: "Live Selfie",
                                subtitle: "(Tap to take Live Photo)",
                                circularPreview: true,
                                previewBytes: _selfiePreview,
                                onTap: () async {
                                  await _pickAndSet(
                                    source: ImageSource.camera,
                                    useFrontCamera: true,
                                    maxSide: 720,
                                    quality: 65,
                                    setPreviewFast: (raw) => setState(() => _selfiePreview = raw),
                                    setB64: (b64) => setState(() => _selfieBase64 = b64),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),
                      _greenButton(text: buttonText, onPressed: _submit),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}