import '../../domain/entities/expense.dart';

abstract class ExpensesEvent {}

class LoadExpenses extends ExpensesEvent {}

class AddExpenseEvent extends ExpensesEvent {
  final Expense expense;
  AddExpenseEvent(this.expense);
}

class DeleteExpenseEvent extends ExpensesEvent {
  final String id;
  DeleteExpenseEvent(this.id);
}
