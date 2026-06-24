import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/models/event.dart';
import '../providers/event_provider.dart';
import '../widgets/concept_ui.dart';
import 'windows_camera_capture_page.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _imagePicker = ImagePicker();

  EventCategory _category = EventCategory.earthquake;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<XFile> _selectedImages = [];
  String? _dateError;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canTakePhoto =
        _usesWindowsDesktopCamera ||
        _imagePicker.supportsImageSource(ImageSource.camera);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: ConceptColors.blue),
        ),
        title: const Text('Create event'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: EventCategory.values.map((category) {
                  return DropdownMenuItem<EventCategory>(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (category) {
                  if (category == null) {
                    return;
                  }

                  setState(() => _category = category);
                },
              ),
              const SizedBox(height: 16),
              _DatePickerField(
                label: 'Start date and time',
                value: _startDate,
                onPressed: _pickStartDate,
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'End date and time',
                value: _endDate,
                onPressed: _pickEndDate,
              ),
              if (_dateError case final error?) ...[
                const SizedBox(height: 8),
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: Icon(Icons.south_america_outlined),
                      ),
                      validator: (value) => _coordinateValidator(
                        value,
                        label: 'Latitude',
                        min: -90,
                        max: 90,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: Icon(Icons.public),
                      ),
                      validator: (value) => _coordinateValidator(
                        value,
                        label: 'Longitude',
                        min: -180,
                        max: 180,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ImageSelectionField(
                images: _selectedImages,
                canTakePhoto: canTakePhoto,
                onPickFromGallery: _pickImagesFromGallery,
                onTakePhoto: _takePhoto,
                onRemove: (image) {
                  setState(() => _selectedImages.remove(image));
                },
                onClear: _selectedImages.isEmpty
                    ? null
                    : () => setState(_selectedImages.clear),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveEvent,
        backgroundColor: ConceptColors.black,
        foregroundColor: Colors.white,
        icon: _isSaving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(_isSaving ? 'Saving' : 'Save event'),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final initialDate = _startDate ?? DateTime.now();
    final pickedDateTime = await _showEventDateTimePicker(
      initialDateTime: initialDate,
    );

    if (!mounted || pickedDateTime == null) {
      return;
    }

    setState(() {
      _startDate = pickedDateTime;
      if (_endDate != null && _endDate!.isBefore(pickedDateTime)) {
        _endDate = pickedDateTime;
      }
      _dateError = null;
    });
  }

  Future<void> _pickEndDate() async {
    final initialDate = _endDate ?? _startDate ?? DateTime.now();
    final pickedDateTime = await _showEventDateTimePicker(
      initialDateTime: initialDate,
    );

    if (!mounted || pickedDateTime == null) {
      return;
    }

    setState(() {
      _endDate = pickedDateTime;
      _dateError = null;
    });
  }

  Future<DateTime?> _showEventDateTimePicker({
    required DateTime initialDateTime,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (!mounted || pickedDate == null) {
      return null;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (pickedTime == null) {
      return null;
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  Future<void> _pickImagesFromGallery() async {
    final List<XFile> images;

    try {
      images = await _imagePicker.pickMultiImage();
    } catch (error) {
      _showImagePickerError(error);
      return;
    }

    if (!mounted || images.isEmpty) {
      return;
    }

    setState(() => _selectedImages.addAll(images));
  }

  Future<void> _takePhoto() async {
    if (_usesWindowsDesktopCamera) {
      final image = await Navigator.of(context).push<XFile>(
        MaterialPageRoute(
          builder: (_) => const WindowsCameraCapturePage(),
        ),
      );

      if (!mounted || image == null) {
        return;
      }

      setState(() => _selectedImages.add(image));
      return;
    }

    final XFile? image;

    try {
      image = await _imagePicker.pickImage(source: ImageSource.camera);
    } catch (error) {
      _showImagePickerError(error);
      return;
    }

    if (!mounted) {
      return;
    }

    if (image == null) {
      return;
    }

    final selectedImage = image;
    setState(() => _selectedImages.add(selectedImage));
  }

  bool get _usesWindowsDesktopCamera {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  void _showImagePickerError(Object error) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open images: $error')),
    );
  }

  Future<void> _saveEvent() async {
    final dateError = _validateDates();

    setState(() => _dateError = dateError);

    if (!(_formKey.currentState?.validate() ?? false) || dateError != null) {
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final event = Event(
      id: 'event-${now.microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _nullableTrimmed(_descriptionController.text),
      category: _category,
      startDate: _startDate!,
      endDate: _endDate!,
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      imagePaths: _selectedImages
          .map((image) => image.path)
          .toList(growable: false),
      createdAt: now,
      updatedAt: now,
    );

    await context.read<EventProvider>().saveEvent(event);

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    final errorMessage = context.read<EventProvider>().errorMessage;
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    Navigator.of(context).pop(event);
  }

  String? _validateDates() {
    if (_startDate == null || _endDate == null) {
      return 'Select both start and end dates.';
    }

    if (_endDate!.isBefore(_startDate!)) {
      return 'End date must be on or after the start date.';
    }

    return null;
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null
        ? 'Select date and time'
        : DateFormat('dd/MM/yyyy HH:mm').format(value!);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calendar_month_outlined),
      label: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              displayValue,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}

class _ImageSelectionField extends StatelessWidget {
  const _ImageSelectionField({
    required this.images,
    required this.canTakePhoto,
    required this.onPickFromGallery,
    required this.onTakePhoto,
    required this.onRemove,
    required this.onClear,
  });

  final List<XFile> images;
  final bool canTakePhoto;
  final VoidCallback onPickFromGallery;
  final VoidCallback onTakePhoto;
  final ValueChanged<XFile> onRemove;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Images',
        prefixIcon: Icon(Icons.image_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isEmpty)
            Text(
              'No images selected',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final image in images)
                  InputChip(
                    label: Text(
                      image.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    avatar: const Icon(Icons.image_outlined, size: 18),
                    onDeleted: () => onRemove(image),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onPickFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Add from gallery'),
              ),
              if (canTakePhoto)
                TextButton.icon(
                  onPressed: onTakePhoto,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Take photo'),
                ),
              if (onClear != null)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear all'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }

  return null;
}

String? _coordinateValidator(
  String? value, {
  required String label,
  required double min,
  required double max,
}) {
  final requiredError = _requiredValidator(value);
  if (requiredError != null) {
    return requiredError;
  }

  final coordinate = double.tryParse(value!.trim());
  if (coordinate == null) {
    return 'Enter a number';
  }

  if (coordinate < min || coordinate > max) {
    return '$label must be between $min and $max';
  }

  return null;
}

String? _nullableTrimmed(String value) {
  final trimmedValue = value.trim();

  if (trimmedValue.isEmpty) {
    return null;
  }

  return trimmedValue;
}
