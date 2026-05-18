import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../providers/transaction_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController amountController;
  late TextEditingController noteController;

  String type = 'expense';

  CategoryModel? selectedCategory;

  late DateTime selectedDate;

  bool get isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );

    noteController = TextEditingController(text: transaction?.note ?? '');

    type = transaction?.type ?? 'expense';

    selectedDate = transaction?.date ?? DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categories = context.read<CategoryProvider>().categories;

      if (categories.isEmpty) return;

      if (transaction != null) {
        try {
          selectedCategory = categories.firstWhere(
            (e) => e.name == transaction.category,
          );
        } catch (_) {
          selectedCategory = categories.first;
        }
      } else {
        selectedCategory = categories.first;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  /// DATE PICKER
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    final now = DateTime.now();

    DateTime updatedDate = DateTime(
      picked.year,
      picked.month,
      picked.day,
      selectedDate.hour,
      selectedDate.minute,
    );

    if (updatedDate.isAfter(now)) {
      updatedDate = now;
    }

    setState(() {
      selectedDate = updatedDate;
    });
  }

  /// TIME PICKER
  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (picked == null) return;

    final now = DateTime.now();

    final newDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      picked.hour,
      picked.minute,
    );

    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (isToday && newDateTime.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Future time not allowed"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      selectedDate = newDateTime;
    });
  }

  /// ADD CATEGORY
  void showAddCategoryDialog() {
    final controller = TextEditingController();

    String selectedIcon = '🍔';

    final icons = [
      '🍔',
      '✈️',
      '🛍️',
      '🎬',
      '🏥',
      '📚',
      '🏋️',
      '💡',
      '💰',
      '🚗',
      '🏠',
      '📱',
    ];

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Text("Add Category"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Category Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: icons.map((icon) {
                        final isSelected = selectedIcon == icon;

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = icon;
                            });
                          },

                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: isSelected
                                ? Colors.deepPurple
                                : Colors.grey.shade200,

                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      return;
                    }

                    final category = CategoryModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),

                      name: controller.text.trim(),

                      icon: selectedIcon,

                      color: Colors.deepPurple,

                      isDefault: false,
                    );

                    context.read<CategoryProvider>().addCategory(category);

                    setState(() {
                      selectedCategory = category;
                    });

                    Navigator.pop(context);
                  },

                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// SAVE TRANSACTION
  void saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select category")));

      return;
    }

    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid amount")));

      return;
    }

    final provider = context.read<TransactionProvider>();

    /// BLOCK EXTRA EXPENSE
    if (type == 'expense') {
      double availableBalance;

      if (isEdit && widget.transaction!.type == 'expense') {
        availableBalance = provider.balance + widget.transaction!.amount;
      } else {
        availableBalance = provider.balance;
      }

      if (amount > availableBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Insufficient balance. Available: Rs ${availableBalance.toStringAsFixed(0)}",
            ),
          ),
        );

        return;
      }
    }

    final now = DateTime.now();

    if (selectedDate.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Future date/time not allowed"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (isEdit) {
      provider.updateTransaction(
        TransactionModel(
          id: widget.transaction!.id,
          amount: amount,
          category: selectedCategory!.name,
          type: type,
          date: selectedDate,
          note: noteController.text.trim(),
        ),
      );
    } else {
      provider.addTransaction(
        amount: amount,
        category: selectedCategory!.name,
        type: type,
        date: selectedDate,
        note: noteController.text.trim(),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,

        title: Text(isEdit ? "Edit Transaction" : "Add Transaction"),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              /// TYPE SWITCH
              Container(
                padding: const EdgeInsets.all(5),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            type = 'expense';
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),

                          decoration: BoxDecoration(
                            color: type == 'expense'
                                ? Colors.red
                                : Colors.transparent,

                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Text(
                            "Expense",
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: type == 'expense'
                                  ? Colors.white
                                  : Colors.black,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            type = 'income';
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),

                          decoration: BoxDecoration(
                            color: type == 'income'
                                ? Colors.green
                                : Colors.transparent,

                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Text(
                            "Income",
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              color: type == 'income'
                                  ? Colors.white
                                  : Colors.black,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// AMOUNT
              TextFormField(
                controller: amountController,

                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter amount";
                  }

                  if (double.tryParse(value) == null) {
                    return "Invalid amount";
                  }

                  return null;
                },

                decoration: InputDecoration(
                  hintText: "0.00",
                  prefixText: "Rs ",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// CATEGORY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CategoryModel?>(
                    value: selectedCategory,
                    isExpanded: true,

                    items: [
                      ...categories.map((e) {
                        return DropdownMenuItem<CategoryModel>(
                          value: e,

                          child: Row(
                            children: [
                              Text(e.icon),

                              const SizedBox(width: 10),

                              Text(e.name),
                            ],
                          ),
                        );
                      }),

                      const DropdownMenuItem<CategoryModel?>(
                        value: null,

                        child: Row(
                          children: [
                            Icon(Icons.add),

                            SizedBox(width: 8),

                            Text("Add Category"),
                          ],
                        ),
                      ),
                    ],

                    onChanged: (value) {
                      if (value == null) {
                        showAddCategoryDialog();
                        return;
                      }

                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// DATE & TIME
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: pickDate,

                      child: Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                DateFormat.yMMMd().format(selectedDate),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GestureDetector(
                      onTap: pickTime,

                      child: Container(
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Row(
                          children: [
                            const Icon(Icons.access_time),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                TimeOfDay.fromDateTime(
                                  selectedDate,
                                ).format(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// NOTE
              TextFormField(
                controller: noteController,
                maxLines: 4,

                decoration: InputDecoration(
                  hintText: "Add note...",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed: saveTransaction,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4DCC),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: Text(
                    isEdit ? "Update Transaction" : "Save Transaction",

                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
