import 'package:flutter/material.dart';

class HealthMetric {
  final String value;
  final String label;
  final String status;
  final Color color;

  HealthMetric({
    required this.value,
    required this.label,
    required this.status,
    required this.color,
  });

  HealthMetric copyWith({String? value, String? label, String? status, Color? color}) {
    return HealthMetric(
      value: value ?? this.value,
      label: label ?? this.label,
      status: status ?? this.status,
      color: color ?? this.color,
    );
  }
}

class HealthMetricCard extends StatefulWidget {
  final HealthMetric metric;
  final Function(String) onUpdate;

  const HealthMetricCard({
    Key? key,
    required this.metric,
    required this.onUpdate,
  }) : super(key: key);

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
        // Lock the value
        widget.onUpdate(_controller.text);
        isEditing = false;
      } else {
        // Start editing
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
              color: Colors.black.withOpacity(0.1),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Value (editable)
                  if (isEditing)
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (value) => _toggleEdit(),
                    )
                  else
                    Text(
                      widget.metric.value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  const Spacer(),
                  // Label
                  Text(
                    widget.metric.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Status (if available)
                  if (widget.metric.status.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.metric.status,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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