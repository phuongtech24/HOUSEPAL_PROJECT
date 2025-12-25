import '../../domain/entities/expense.dart';

abstract class ExpensesState {}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<Expense> items;
  ExpensesLoaded(this.items);
}

class ExpensesError extends ExpensesState {
  final String message;
  ExpensesError(this.message);
}
