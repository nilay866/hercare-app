import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/ui_utils.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  List<dynamic> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final auth = context.read<AuthProvider>();
    try {
      final data = await ApiService.getDietPlans(patientId: auth.userId!, token: auth.token!);
      setState(() { _plans = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addMeal() async {
    final foodCtrl = TextEditingController();
    final caloriesCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String mealType = 'breakfast';

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Add Meal Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [
                _mealChip(ctx, 'Breakfast', '🌅', 'breakfast', mealType, (v) => setModalState(() => mealType = v)),
                const SizedBox(width: 8),
                _mealChip(ctx, 'Lunch', '☀️', 'lunch', mealType, (v) => setModalState(() => mealType = v)),
                const SizedBox(width: 8),
                _mealChip(ctx, 'Snack', '🍿', 'snack', mealType, (v) => setModalState(() => mealType = v)),
                const SizedBox(width: 8),
                _mealChip(ctx, 'Dinner', '🌙', 'dinner', mealType, (v) => setModalState(() => mealType = v)),
              ]),
              const SizedBox(height: 16),
              TextField(
                controller: foodCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Food Items',
                  hintText: 'e.g. Oatmeal, Fruits, Milk, Nuts...',
                  prefixIcon: const Icon(Icons.restaurant),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories (optional)',
                  hintText: 'e.g. 350',
                  prefixIcon: const Icon(Icons.local_fire_department),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Doctor\'s Notes',
                  hintText: 'Any special instructions...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (foodCtrl.text.isNotEmpty) Navigator.pop(ctx, true);
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Meal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );

    if (result == true) {
      final auth = context.read<AuthProvider>();
      try {
        await ApiService.createDietPlan(
          body: {
            'patient_id': auth.userId,
            'meal_type': mealType,
            'food_items': foodCtrl.text,
            'calories': int.tryParse(caloriesCtrl.text),
            'notes': notesCtrl.text,
          },
          token: auth.token!,
        );
        if (mounted) UiUtils.showSuccess(context, 'Meal added!');
        _loadPlans();
      } catch (e) {
        if (mounted) UiUtils.showError(context, e.toString());
      }
    }
  }

  Widget _mealChip(BuildContext ctx, String label, String emoji, String value, String current, Function(String) onTap) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4CAF50).withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? const Color(0xFF4CAF50) : Colors.transparent, width: 2),
          ),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: selected ? const Color(0xFF4CAF50) : Colors.grey)),
          ]),
        ),
      ),
    );
  }

  final _mealData = {
    'breakfast': {'emoji': '🌅', 'color': const Color(0xFFFF9800), 'time': '7:00 - 9:00 AM'},
    'lunch': {'emoji': '☀️', 'color': const Color(0xFF4CAF50), 'time': '12:00 - 2:00 PM'},
    'snack': {'emoji': '🍿', 'color': const Color(0xFF7C4DFF), 'time': '4:00 - 5:00 PM'},
    'dinner': {'emoji': '🌙', 'color': const Color(0xFF2196F3), 'time': '7:00 - 9:00 PM'},
  };

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<dynamic>>{};
    for (final p in _plans) {
      final type = p['meal_type'] ?? 'other';
      grouped.putIfAbsent(type, () => []).add(p);
    }

    final mealOrder = ['breakfast', 'lunch', 'snack', 'dinner'];

    return Scaffold(
      appBar: AppBar(title: const Text('Diet Plan')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeal,
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('No diet plan yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text('Your doctor can create a plan for you', style: TextStyle(color: Colors.grey.shade400)),
                ]))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Calorie Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        Column(children: [
                          const Icon(Icons.local_fire_department, color: Colors.white, size: 28),
                          const SizedBox(height: 4),
                          Text('${_plans.fold<int>(0, (sum, p) => sum + ((p['calories'] as int?) ?? 0))}',
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text('Total Cal', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ]),
                        Column(children: [
                          const Icon(Icons.restaurant, color: Colors.white, size: 28),
                          const SizedBox(height: 4),
                          Text('${_plans.length}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text('Meals', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    ...mealOrder.where((m) => grouped.containsKey(m)).map((meal) {
                      final items = grouped[meal]!;
                      final data = _mealData[meal]!;
                      final color = data['color'] as Color;
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(data['emoji'] as String, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(meal[0].toUpperCase() + meal.substring(1),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                          const Spacer(),
                          Text(data['time'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ]),
                        const SizedBox(height: 8),
                        ...items.map((p) => Dismissible(
                          key: Key(p['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            final auth = context.read<AuthProvider>();
                            await ApiService.deleteDietPlan(planId: p['id'], token: auth.token!);
                            setState(() => _plans.remove(p));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: color.withValues(alpha: 0.2)),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(p['food_items'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                              if (p['calories'] != null) ...[
                                const SizedBox(height: 4),
                                Row(children: [
                                  Icon(Icons.local_fire_department, size: 14, color: color),
                                  const SizedBox(width: 4),
                                  Text('${p['calories']} cal', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                                ]),
                              ],
                              if (p['notes'] != null && p['notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('📝 ${p['notes']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                              ],
                            ]),
                          ),
                        )),
                        const SizedBox(height: 12),
                      ]);
                    }),
                  ],
                ),
    );
  }
}
