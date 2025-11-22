import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthMetric {
  final String value;
  final String unit;
  final String label;
  final Color color;
  final List<double> trend;

  HealthMetric({
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
    this.trend = const [],
  });

  HealthMetric copyWith({String? value, String? unit, String? label, String? status, List<double>? trend, Color? color}) {
    return HealthMetric(
      value: value ?? this.value,
      unit: unit ?? this.unit,
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }
}

class HealthMetricCard extends StatefulWidget {
  final HealthMetric metric;
  final ValueChanged<String> onUpdate; 
  
  const HealthMetricCard({
    super.key,
    required this.metric,
    required this.onUpdate,
  });

  @override
  State<HealthMetricCard> createState() => _HealthMetricCardState();
}

class _HealthMetricCardState extends State<HealthMetricCard> {
  bool isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.metric.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (isEditing) {
        // handle empty values by updating with a default string
        final newValue = _controller.text.isNotEmpty ? _controller.text : 'Not Available';
        widget.onUpdate(newValue);
        isEditing = false;
      } else {
        isEditing = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleEdit,
      child: Container(
        decoration: BoxDecoration(
          color: widget.metric.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Value (editable)
                  if (isEditing)
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 1,
                      minLines: 1,
                      onSubmitted: (value) {
                        // Handle when editing is finished
                        final updatedValue = value.isNotEmpty ? value : 'Not Available';  // Set default if empty
                        widget.onUpdate(updatedValue);
                        _toggleEdit();
                        },
                      )
                    else
                      Text(
                        widget.metric.value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                  // Unit of Measure
                  Text(
                    widget.metric.unit,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Label
                  Text(
                    widget.metric.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Edit indicator
            if (isEditing)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HealthMetricWidgetFactory
{ 
  final supabase = Supabase.instance.client; 
  
  Future<List<Map<String, dynamic>>> fetchMeasurementAttributes() async 
  { 
    final response = await supabase 
      .from('measurementattributes')
      .select()
      .order('id', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
    
  }

  Color parseHexColor(String hex)
  { 
    hex = hex.replaceFirst('#', '').replaceAll('0x', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<List<HealthMetric>> createHealthWidgets() async 
  { 
    final attributes = await fetchMeasurementAttributes(); 
    return attributes.map((attr) 
    { 
      return HealthMetric(
        value: '',
        unit: attr['measurementunit'] ?? '',
        label: attr['fullname'],
        color: parseHexColor(attr['color'])
      );
    }).toList();
  }
}