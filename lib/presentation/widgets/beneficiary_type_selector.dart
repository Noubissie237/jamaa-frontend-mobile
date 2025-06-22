import 'package:flutter/material.dart';
import 'package:jamaa_frontend_mobile/presentation/widgets/build_user_transfer_tab.dart';

class BeneficiaryTypeSelector extends StatelessWidget {
  final BeneficiaryType selectedType;
  final ValueChanged<BeneficiaryType> onTypeChanged;

  const BeneficiaryTypeSelector({
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: BeneficiaryType.values.map((type) {
          final isSelected = type == selectedType;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected 
                          ? Colors.white 
                          : Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.label,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 10,
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
